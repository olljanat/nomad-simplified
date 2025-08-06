# Add CoreDNS with Nomad integration support
ARG COREDNS_NOMAD_VERSION
FROM ghcr.io/ituoga/coredns-nomad:v${COREDNS_NOMAD_VERSION} AS coredns

# Build target container
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y ca-certificates curl iputils-ping net-tools traceroute
COPY --from=coredns /coredns /bin/
RUN mkdir -p /etc/coredns
COPY /coredns /etc/coredns

# Add Nomad
ARG NOMAD_VERSION
ADD https://github.com/olljanat/nomad/releases/download/v1.10.3-olljanat1/nomad_linux_amd64.zip /tmp/nomad.zip
RUN mkdir -p /etc/nomad.d /opt/nomad \
    && unzip -o /tmp/nomad.zip -d /bin \
    && chmod 0755 /bin/nomad
COPY /nomad.d /etc/nomad.d

# Remove Windows specific files
RUN rm -f /etc/nomad.d/windows.hcl

# Add client entry script
COPY /client-entry.sh /bin/
