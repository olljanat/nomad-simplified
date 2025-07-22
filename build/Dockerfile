FROM debian:bookworm-slim
RUN apt-get update \
	&& apt-get install -y gpg iproute2 libcap2-bin wget \
	&& wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
	&& echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" | tee /etc/apt/sources.list.d/hashicorp.list \
	&& apt-get update \
	&& apt-get install -y consul consul-template nomad vault \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /opt/* \
	&& rm -rf /etc/consul.d/* \
	&& rm -rf /etc/nomad.d/* \
	&& rm -rf /etc/vault.d/

RUN groupadd hashistack \
	&& usermod -a -G hashistack consul \
	&& usermod -a -G hashistack nomad \
	&& usermod -a -G hashistack vault

COPY /consul.d /etc/consul.d
COPY /nomad.d /etc/nomad.d
# COPY /vault.d /etc/vault.d

# Remove Windows specific files
RUN rm -f /etc/consul.d/windows.hcl
RUN rm -f /etc/nomad.d/windows.hcl

COPY /entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
