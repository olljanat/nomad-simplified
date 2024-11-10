#!/bin/sh
apk --no-cache add jq

export VAULT_TOKEN=$(cat /opt/vault/secrets/vault_token)

vault secrets enable -path=secret/generic/ kv-v2
vault secrets enable -path=secret/environments/ kv-v2

vault secrets enable -path=consul pki
vault secrets tune -max-lease-ttl=87600h consul

vault write -field=certificate consul/root/generate/internal \
  common_name="Nomad Simplified Root CA" \
  issuer_name="s" \
  ttl=87600h > /opt/vault/data/ca.crt
vault write consul/config/urls \
    issuing_certificates="https://127.0.0.1:8200/v1/consul/ca" \
    crl_distribution_points="https://127.0.0.1:8200/v1/consul/crl"

vault secrets enable -path=consul-ca pki
vault secrets tune -max-lease-ttl=43800h consul-ca

vault write -format=json consul-ca/intermediate/generate/internal \
    common_name="Nomad Simplified Issuing CA" \
    | jq -r '.data.csr' > intermediate.csr
vault write -format=json consul/root/sign-intermediate csr=@intermediate.csr \
    format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > /opt/vault/data/intermediate.cert.pem
vault write consul-ca/intermediate/set-signed certificate=@/opt/vault/data/intermediate.cert.pem

vault write consul-ca/config/urls \
  issuing_certificates="https://127.0.0.1:8200/v1/consul-ca/ca" \
  crl_distribution_points="https://127.0.0.1:8200/v1/consul-ca/crl"

vault write consul-ca/roles/consulcerts \
  allowed_domains="nomad-simplified.local" \
  allow_subdomains=true \
  max_ttl=8760h
