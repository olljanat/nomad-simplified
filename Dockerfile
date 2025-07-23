# Add CoreDNS with Nomad integration support
ARG COREDNS_NOMAD_VERSION
FROM ghcr.io/ituoga/coredns-nomad:v${COREDNS_NOMAD_VERSION} AS coredns
FROM busybox:1.37
COPY --from=coredns /coredns /bin/
RUN mkdir -p /etc/coredns
COPY /coredns /etc/coredns

# Add Nomad
ARG NOMAD_VERSION
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip /tmp/nomad.zip
RUN mkdir -p /etc/nomad.d /opt/nomad \
    && unzip -o /tmp/nomad.zip -d /bin
COPY /nomad.d /etc/nomad.d

# Remove Windows specific files
RUN rm -f /etc/nomad.d/windows.hcl
