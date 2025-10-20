# Add CoreDNS
ARG COREDNS_VERSION=unknown
FROM coredns/coredns:${COREDNS_VERSION} AS coredns

# Build target container
FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y ca-certificates curl iproute2 iputils-ping net-tools traceroute unzip wget
COPY --from=coredns /coredns /bin/
RUN mkdir -p /etc/coredns
COPY /coredns /etc/coredns

# Add Nomad
ARG NOMAD_VERSION=unknown
ADD https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip /tmp/nomad.zip
RUN mkdir -p /etc/nomad.d /opt/nomad \
    && unzip -o /tmp/nomad.zip -d /bin \
    && chmod 0755 /bin/nomad
COPY /nomad.d /etc/nomad.d

# Remove Windows specific files
RUN rm -f /etc/nomad.d/windows.hcl

# Add entry scripts
COPY /client-entry.sh /bin/
COPY /server-entry.sh /bin/

