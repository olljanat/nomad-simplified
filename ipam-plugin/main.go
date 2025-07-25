package main

import (
	"fmt"
	"os"
	"regexp"

	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/sirupsen/logrus"
)

var (
	log       = logger()
	validName = regexp.MustCompile(`^[a-z0-9][a-z0-9_.-]*$`)
	Version   string
)

type ipamDriver struct{}

type simpleFormatter struct{}

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
