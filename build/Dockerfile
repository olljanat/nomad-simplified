FROM debian:bookworm-slim
RUN apt-get update \
        && apt-get install -y gpg libcap2-bin wget \
        && wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bullseye main" | tee /etc/apt/sources.list.d/hashicorp.list \
        && apt-get update \
        && apt-get install -y consul consul-template nomad vault \
        && rm -rf /var/lib/apt/lists/* \
	&& rm -rf /opt/* \
	&& rm -rf /etc/consul.d/* \
	&& rm -rf /etc/nomad.d/* \
	&& rm -rf /etc/vault.d/
