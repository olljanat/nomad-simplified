package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/sirupsen/logrus"
)

var (
	log     = logger()
	Version string
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
	/*
		if r.Options["RequestAddressType"] == "com.docker.network.gateway" {
			return &ipam.RequestAddressResponse{Address: r.PoolID}, nil
		}
	*/
	fmt.Printf("RequestAddress, request options: %v\n", r.Options)
	return &ipam.RequestAddressResponse{Address: "100.64.255.201/24", Data: r.Options}, nil
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
