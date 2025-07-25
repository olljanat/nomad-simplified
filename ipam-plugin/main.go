package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/sirupsen/logrus"
)

var (
	log        = logger()
	Version    string
	driverName = "nomad-ipam"
)

type ipamDriver struct{}

type simpleFormatter struct{}

func (d *ipamDriver) GetCapabilities() (*ipam.CapabilitiesResponse, error) {
	fmt.Printf("GetCapabilities()\n")
	return &ipam.CapabilitiesResponse{
		RequiresMACAddress:    false,
		RequiresRequestReplay: false,
	}, nil
}

func (d *ipamDriver) GetDefaultAddressSpaces() (*ipam.AddressSpacesResponse, error) {
	fmt.Printf("GetDefaultAddressSpaces()\n")
	return &ipam.AddressSpacesResponse{LocalDefaultAddressSpace: "local",
		GlobalDefaultAddressSpace: "global"}, nil
}

func (d *ipamDriver) RequestPool(r *ipam.RequestPoolRequest) (*ipam.RequestPoolResponse, error) {
	fmt.Printf("RequestPool()\n")
	if r.Pool == "" {
		return &ipam.RequestPoolResponse{}, errors.New("--subnet parameter is required")
	}
	return &ipam.RequestPoolResponse{PoolID: r.Pool, Pool: r.Pool}, nil
}

func (d *ipamDriver) ReleasePool(r *ipam.ReleasePoolRequest) error {
	fmt.Printf("ReleasePool()\n")
	return nil
}

func (d *ipamDriver) RequestAddress(r *ipam.RequestAddressRequest) (*ipam.RequestAddressResponse, error) {
	fmt.Printf("RequestAddress, request options: %v\n", r.Options)
	if r.Options["RequestAddressType"] == "com.docker.network.gateway" {
		return &ipam.RequestAddressResponse{Address: "10.0.0.1/16"}, nil
	}
	return &ipam.RequestAddressResponse{Address: "10.0.3.1/16"}, nil
}

func (d *ipamDriver) ReleaseAddress(r *ipam.ReleaseAddressRequest) error {
	fmt.Printf("ReleaseAddress()\n")
	return nil
}

func main() {
	if len(os.Args) > 1 && os.Args[1] == "-V" {
		fmt.Printf("Version: %s\n", Version)
		return
	}

	log.SetFormatter(&simpleFormatter{})

	d := &ipamDriver{}
	h := ipam.NewHandler(d)

	log.Infof("Starting ipam plugin\n")
	serve(h)

}

func (f *simpleFormatter) Format(entry *logrus.Entry) ([]byte, error) {
	return []byte(entry.Message + ""), nil
}
