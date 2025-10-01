# Add CoreDNS with Nomad integration support
# ARG COREDNS_NOMAD_VERSION
# FROM ollijanatuinen/coredns:amd64-v20250820-1 AS coredns
# FROM ghcr.io/ituoga/coredns-nomad:v${COREDNS_NOMAD_VERSION} AS coredns

# Build target container
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y ca-certificates curl iproute2 iputils-ping net-tools traceroute unzip wget
# COPY --from=coredns /coredns /bin/
ADD https://github.com/olljanat/coredns/releases/download/1.13.0-dev/coredns /bin/coredns
RUN mkdir -p /etc/coredns \
    && chmod 0755 /bin/coredns
COPY /coredns /etc/coredns

# Add Nomad
ARG NOMAD_VERSION
ADD https://github.com/olljanat/nomad/releases/download/${NOMAD_VERSION}/linux_amd64.zip /tmp/nomad.zip
RUN mkdir -p /etc/nomad.d /opt/nomad \
    && unzip -o /tmp/nomad.zip -d /bin \
    && chmod 0755 /bin/nomad
COPY /nomad.d /etc/nomad.d

# Remove Windows specific files
RUN rm -f /etc/nomad.d/windows.hcl

# Add entry scripts
COPY /client-entry.sh /bin/
COPY /server-entry.sh /bin/

