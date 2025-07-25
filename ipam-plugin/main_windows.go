//go:build windows

package main

import (
	"io"

	"github.com/Freman/eventloghook"
	"github.com/docker/go-plugins-helpers/ipam"
	"github.com/docker/go-plugins-helpers/sdk"
	"github.com/sirupsen/logrus"
	"golang.org/x/sys/windows/svc"
	"golang.org/x/sys/windows/svc/eventlog"
)

var (
	npipe       = "//./pipe/docker-nomad-ipam-plugin"
	ServiceName = "docker-nomad-ipam"
)

type program struct {
	h *ipam.Handler
}

func (p *program) Execute(args []string, r <-chan svc.ChangeRequest, s chan<- svc.Status) (bool, uint32) {
	const cmdsAccepted = svc.AcceptStop | svc.AcceptShutdown
	s <- svc.Status{State: svc.StartPending}
	go p.run(false)
	s <- svc.Status{State: svc.Running, Accepts: cmdsAccepted}

loop:
	for c := range r {
		switch c.Cmd {
		case svc.Interrogate:
			s <- c.CurrentStatus
		case svc.Stop, svc.Shutdown:
			break loop
		}
	}
	s <- svc.Status{State: svc.StopPending}
	return false, 0
}

func (p *program) run(debug bool) {

	sd := sdk.AllowServiceSystemAdmin
	if !debug {
		sd = sdk.AllowSystemOnly
	}

	config := sdk.WindowsPipeConfig{
		SecurityDescriptor: sd,
		InBufferSize:       4096,
		OutBufferSize:      4096,
	}
	if err := p.h.ServeWindows(npipe, "nomad", sdk.WindowsDefaultDaemonRootDir(), &config); err != nil {
		logrus.Errorf("Error serving ipam plugin: %v", err)
	}
}

func serve(h *ipam.Handler) {
	prg := &program{h: h}
	if isSvc, err := svc.IsWindowsService(); err == nil && !isSvc {
		log.Infof("Running in interactive mode")
		prg.run(true)
		return
	}
	log.SetOutput(io.Discard)
	err := svc.Run(ServiceName, prg)
	if err != nil {
		log.Fatalf("Failed to start service: %v ", err)
	}
}

func logger() *logrus.Logger {
	log := logrus.New()
	elog, err := eventlog.Open(ServiceName)
	if err != nil {
		panic(err)
	}
	hook := eventloghook.NewHook(*elog)
	log.Hooks.Add(hook)
	return log
}
