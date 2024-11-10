

# Sources
https://github.com/hashicorp/learn-consul-docker/tree/main/datacenter-deploy-hashistack
https://github.com/testdrivenio/vault-consul-docker/blob/master/docker-compose.yml
https://github.com/rms1000watt/nomad/blob/master/docker-compose.yml
https://github.com/covermymeds/azure-key-vault-agent

# Testing
az ad sp create-for-rbac -n nomad-simplified --years 30

export AZURE_TENANT_ID="d9007062-1aae-4619-abb0-320699664975"
export AZURE_CLIENT_ID="e0f366eb-82cb-4037-98f5-2b632147615f"
export AZURE_CLIENT_SECRET="LCj8Q~hnnqa.utk5ypOpe_Jdxgr0C_Z3HuDQHaB3"
export VAULT_AZUREKEYVAULT_VAULT_NAME="kv-nomad-simplified"
export VAULT_AZUREKEYVAULT_KEY_NAME="test-automation"
source .versions

docker compose -f lab.yml up -d
./vault-init.sh

export VAULT_TOKEN=$(cat vault/secrets/vault_token)
docker exec -it node1 docker compose up
