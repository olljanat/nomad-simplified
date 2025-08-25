# Add CoreDNS with Nomad integration support
ARG COREDNS_NOMAD_VERSION
FROM ollijanatuinen/coredns:amd64-v20250820-1 AS coredns
# FROM ghcr.io/ituoga/coredns-nomad:v${COREDNS_NOMAD_VERSION} AS coredns

# Build target container
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y ca-certificates curl iproute2 iputils-ping net-tools traceroute unzip wget
COPY --from=coredns /coredns /bin/
RUN mkdir -p /etc/coredns
COPY /coredns /etc/coredns

# Add Nomad
ARG NOMAD_VERSION
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip /tmp/nomad.zip
RUN mkdir -p /etc/nomad.d /opt/nomad \
    && unzip -o /tmp/nomad.zip -d /bin \
    && chmod 0755 /bin/nomad
COPY /nomad.d /etc/nomad.d

# Remove Windows specific files
RUN rm -f /etc/nomad.d/windows.hcl

# Add entry scripts
COPY /client-entry.sh /bin/
COPY /servers-entry.sh /bin/

