module github.com/olljanat/nomad-simplified/ipam-plugin

go 1.24.5

require (
	github.com/Freman/eventloghook v0.0.0-20250521070251-ac7a0abdf09a
	github.com/docker/go-plugins-helpers v0.0.0-20240701071450-45e2431495c8
	github.com/sirupsen/logrus v1.9.3
	golang.org/x/sys v0.34.0
)

require (
	github.com/Microsoft/go-winio v0.6.2 // indirect
	github.com/coreos/go-systemd v0.0.0-20191104093116-d3cd4ed1dbcf // indirect
	github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
	github.com/docker/go-connections v0.5.0 // indirect
	github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2 // indirect
	github.com/stretchr/testify v1.10.0 // indirect
)

replace github.com/docker/go-plugins-helpers v0.0.0-20240701071450-45e2431495c8 => github.com/olljanat/go-plugins-helpers v0.0.0-20250515164337-e76ac885ec0e
