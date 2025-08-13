package main

import (
	"errors"
	"fmt"
	"net"
	"os"
	"strings"
	"sync"

	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/hashicorp/nomad/api"
)

var (
	log        = logger()
	Version    string
	driverName = "nomad-ipam"
	datacenter string

	// Keep track of used IPs in this node
	usedLocalIPs     = make(map[string]bool)
	usedLocalIPsLock sync.RWMutex
)

type ipamDriver struct {
	nomadClient *api.Client
}

type simpleFormatter struct{}

func NewipamDriver() (*ipamDriver, error) {
	nomadConfig := api.DefaultConfig()
	nomadClient, err := api.NewClient(nomadConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to create Nomad client: %v", err)
	}

	return &ipamDriver{
		nomadClient: nomadClient,
	}, nil
}

func (d *ipamDriver) GetCapabilities() (*ipam.CapabilitiesResponse, error) {
	return &ipam.CapabilitiesResponse{
		RequiresMACAddress:    false,
		RequiresRequestReplay: false,
	}, nil
}

func (d *ipamDriver) GetDefaultAddressSpaces() (*ipam.AddressSpacesResponse, error) {
	return &ipam.AddressSpacesResponse{
		LocalDefaultAddressSpace:  "local",
		GlobalDefaultAddressSpace: "global",
	}, nil
}

func (d *ipamDriver) RequestPool(r *ipam.RequestPoolRequest) (*ipam.RequestPoolResponse, error) {
	if r.Pool == "" {
		return &ipam.RequestPoolResponse{}, errors.New("--subnet parameter is required")
	}
	return &ipam.RequestPoolResponse{PoolID: r.Pool, Pool: r.Pool}, nil
}

func (d *ipamDriver) ReleasePool(r *ipam.ReleasePoolRequest) error {
	return nil
}

func (d *ipamDriver) RequestAddress(r *ipam.RequestAddressRequest) (*ipam.RequestAddressResponse, error) {
	// Determine subnet mask from PoolID
	mask := 32
	_, ipNet, err := net.ParseCIDR(r.PoolID)
	if err == nil {
		mask, _ = ipNet.Mask.Size()
	}

	// Handle gateway address request
	if r.Options["RequestAddressType"] == "com.docker.network.gateway" {
		if r.Address == "" {
			return &ipam.RequestAddressResponse{}, errors.New("--gateway parameter is required")
		}
		return &ipam.RequestAddressResponse{Address: fmt.Sprintf("%s/%d", r.Address, mask)}, nil
	}

	// Extract endpoint name (container name) from options
	// Requires Docker version containing: https://github.com/moby/moby/pull/50586
	endpointName, ok := r.Options["com.docker.network.endpoint.name"]
	if !ok || endpointName == "" {
		return nil, fmt.Errorf("missing or invalid com.docker.network.endpoint.name in request options")
	}

	// Extract allocation ID from container name
	// https://github.com/hashicorp/nomad/blob/v1.10.3/drivers/docker/driver.go#L1430
	parts := strings.Split(endpointName, "-")
	if len(parts) < 5 {
		return nil, fmt.Errorf("invalid container name format: %s", endpointName)
	}
	allocID := strings.Join(parts[len(parts)-5:], "-")

	// Get allocation details from Nomad
	allocationsAPI := d.nomadClient.Allocations()
	alloc, _, err := allocationsAPI.Info(allocID, &api.QueryOptions{})
	if err != nil {
		return nil, fmt.Errorf("failed to get allocation %s: %v", allocID, err)
	}

	// Get CIDR from Nomad namespace metadata
	namespacesAPI := d.nomadClient.Namespaces()
	ns, _, err := namespacesAPI.Info(alloc.Namespace, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to get namespace %s: %v", alloc.Namespace, err)
	}
	fieldName := "ip_range_" + datacenter
	ipRange, ok := ns.Meta[fieldName]
	if !ok {
		return nil, fmt.Errorf("no %s metadata found for namespace %s", fieldName, alloc.Namespace)
	}
	_, ipNet, err = net.ParseCIDR(ipRange)
	if err != nil {
		return nil, fmt.Errorf("invalid %s format %s in namespace %s: %v", fieldName, ipRange, alloc.Namespace, err)
	}

	// Get IPs included to service registrations.
	// TODO: This will not prevent IP conflicts in situation where job is deployed without service registration.
	usedIPs := make(map[string]bool)

	servicesAPI := d.nomadClient.Services()
	services, _, err := servicesAPI.List(&api.QueryOptions{Namespace: alloc.Namespace})
	if err != nil {
		return nil, fmt.Errorf("failed to list services in namespace %s: %v", alloc.Namespace, err)
	}
	for _, serviceStub := range services {
		for _, service := range serviceStub.Services {
			fmt.Printf("Processing service: %v \n", service.ServiceName)
			serviceRegistrations, _, err := servicesAPI.Get(service.ServiceName, &api.QueryOptions{Namespace: alloc.Namespace})
			if err != nil {
				return nil, fmt.Errorf("failed to service registration for service %s: %v", service.ServiceName, err)
			}
			for _, sr := range serviceRegistrations {
				if sr.Datacenter != datacenter {
					continue
				}
				usedIPs[sr.Address] = true
			}
		}
	}

	// Find a free IP in the subnet
	freeIP := findFirstFreeIP(ipNet, usedIPs)
	if freeIP == "" {
		return nil, fmt.Errorf("no free IP found in ip_range %s for namespace %s in datacenter %s", ipRange, alloc.Namespace, datacenter)
	}

	usedLocalIPsLock.Lock()
	usedLocalIPs[freeIP] = true
	usedLocalIPsLock.Unlock()

	return &ipam.RequestAddressResponse{
		Address: fmt.Sprintf("%s/%d", freeIP, mask),
	}, nil
}

func (d *ipamDriver) ReleaseAddress(r *ipam.ReleaseAddressRequest) error {

	usedLocalIPsLock.Lock()
	usedLocalIPs[r.Address] = false
	usedLocalIPsLock.Unlock()

	return nil
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "-V" {
		fmt.Printf("Version: %s\n", Version)
		return
	}

	log.SetFormatter(&simpleFormatter{})

	datacenter = os.Getenv("NOMAD_DATACENTER")
	if datacenter == "" {
		log.Fatal("NOMAD_DATACENTER environment variable is required")
	}

	d, err := NewipamDriver()
	if err != nil {
		log.Fatalf("Failed to initialize IPAM driver: %v", err)
	}
	h := ipam.NewHandler(d)

	log.Infof("Starting Nomad IPAM plugin\n")
	serve(h)
}
