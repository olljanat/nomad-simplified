package main

import (
	"errors"
	"fmt"
	"net"
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
	return &ipam.CapabilitiesResponse{RequiresMACAddress: true}, nil
}

func (d *ipamDriver) GetDefaultAddressSpaces() (*ipam.AddressSpacesResponse, error) {
	return &ipam.AddressSpacesResponse{LocalDefaultAddressSpace: "local",
		GlobalDefaultAddressSpace: "global"}, nil
}

func (d *ipamDriver) RequestPool(r *ipam.RequestPoolRequest) (*ipam.RequestPoolResponse, error) {
	pool := ""
	if r.V6 {
		if r.Options["v6subnet"] == "" {
			return &ipam.RequestPoolResponse{}, errors.New("IPv6 subnet is required")
		}
		pool = r.Options["v6subnet"]
	} else {
		if r.Pool == "" {
			return &ipam.RequestPoolResponse{PoolID: "0.0.0.0/32", Pool: "0.0.0.0/32"}, nil
		}
		pool = r.Pool
	}

	_, ipnet, err := net.ParseCIDR(pool)
	if err != nil {
		return &ipam.RequestPoolResponse{}, err
	}
	mask, _ := ipnet.Mask.Size()
	if !r.V6 && mask != 32 {
		return &ipam.RequestPoolResponse{}, errors.New("only subnet mask /32 is supported")
	}
	if r.V6 && mask != 128 {
		return &ipam.RequestPoolResponse{}, errors.New("only subnet mask /128 is supported")
	}

	return &ipam.RequestPoolResponse{PoolID: pool, Pool: pool}, nil
}

func (d *ipamDriver) ReleasePool(r *ipam.ReleasePoolRequest) error {
	return nil
}

func (d *ipamDriver) RequestAddress(r *ipam.RequestAddressRequest) (*ipam.RequestAddressResponse, error) {
	if r.Options["RequestAddressType"] == "com.docker.network.gateway" {
		return &ipam.RequestAddressResponse{Address: r.PoolID}, nil
	}

	return &ipam.RequestAddressResponse{Address: r.PoolID}, nil
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

	d := &ipamDriver{}
	h := ipam.NewHandler(d)

	log.Infof("Starting ipam plugin")
	serve(h)

}

func (f *simpleFormatter) Format(entry *logrus.Entry) ([]byte, error) {
	return []byte(entry.Message + ""), nil
}
