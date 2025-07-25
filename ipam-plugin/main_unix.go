//go:build linux

package main

import (
	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/sirupsen/logrus"
)

func serve(h *ipam.Handler) {
	if err := h.ServeUnix(driverName, 0); err != nil {
		log.Errorf("Error serving ipam plugin: %v", err)
	}
}

func logger() *logrus.Logger {
	return logrus.New()
}
