package main

import (
	"errors"
	"fmt"
	"net"
	"os"
	"strings"

	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/hashicorp/nomad/api"
)

var (
	log        = logger()
	Version    string
	driverName = "nomad-ipam"
	datacenter string
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
	mask := 32
	_, ipNet, err := net.ParseCIDR(r.PoolID)
	if err == nil {
		mask, _ = ipNet.Mask.Size()
	}

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

	// Get namespace from allocation
	namespace := alloc.Namespace
	if namespace == "" {
		return nil, fmt.Errorf("no namespace found for allocation %s", allocID)
	}

	// Get CIDR from Nomad namespace metadata
	namespacesAPI := d.nomadClient.Namespaces()
	ns, _, err := namespacesAPI.Info(namespace, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to get namespace %s: %v", namespace, err)
	}
	fieldName := "ip_range_" + datacenter
	ipRange, ok := ns.Meta[fieldName]
	if !ok {
		return nil, fmt.Errorf("no %s metadata found for namespace %s", fieldName, namespace)
	}
	_, ipNet, err = net.ParseCIDR(ipRange)
	if err != nil {
		return nil, fmt.Errorf("invalid %s format %s in namespace %s: %v", fieldName, ipRange, namespace, err)
	}

	// Get all jobs in the namespace
	jobsAPI := d.nomadClient.Jobs()
	jobs, _, err := jobsAPI.List(&api.QueryOptions{Namespace: namespace})
	if err != nil {
		return nil, fmt.Errorf("failed to list jobs in namespace %s: %v", namespace, err)
	}

	// Collect IPs used by allocations
	usedIPs := make(map[rune]bool)
	for _, jobStub := range jobs {
		allocs, _, err := d.nomadClient.Jobs().Allocations(jobStub.ID, false, &api.QueryOptions{Namespace: namespace})
		if err != nil {
			log.Printf("Failed to list allocations for job %s in namespace %s: %v", jobStub.ID, namespace, err)
			continue
		}
		for _, alloc := range allocs {
			if alloc.AllocatedResources != nil && alloc.AllocatedResources.Shared.Networks != nil {
				for _, network := range alloc.AllocatedResources.Shared.Networks {
					for _, ip := range network.IP {
						usedIPs[ip] = true
					}
				}
			}
		}
	}

	freeIP := findFirstFreeIP(ipNet, usedIPs)
	if freeIP == "" {
		return nil, fmt.Errorf("no free IP found in ip_range %s for namespace %s", ipRange, namespace)
	}

	return &ipam.RequestAddressResponse{
		Address: fmt.Sprintf("%s/%d", freeIP, mask),
	}, nil
}

func (d *ipamDriver) ReleaseAddress(r *ipam.ReleaseAddressRequest) error {
	return nil
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "-V" {
		fmt.Printf("Version: %s\n", Version)
		return
	}

	log.SetFormatter(&simpleFormatter{})

	datacenter = os.Getenv("DATACENTER")
	if datacenter == "" {
		log.Fatal("DATACENTER environment variable is required")
	}

	d, err := NewipamDriver()
	if err != nil {
		log.Fatalf("Failed to initialize IPAM driver: %v", err)
	}
	h := ipam.NewHandler(d)

	log.Infof("Starting ipam plugin\n")
	serve(h)
}
