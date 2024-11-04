#!/usr/bin/sh

if [ "${VAULT_TOKEN:-x}" == "x" ]; then
  echo ""
  echo "!!Missing VAULT_TOKEN environment variable!!"
  echo ""
  exit 1
fi

TF_LOG_LEVEL=INFO
TF_PLAN="proxmox-okd4"
TF_PROXMOX_DATA="./terraform-vars/production.yaml"

ansible -i proxmox2.lan, all -m shell -a 'for vmid in 201 202 203 204 205 206; do qm stop $vmid; done'
# ansible -i proxmox.lan, all -m shell -a 'for vmid in 204 205; do qm stop $vmid; done'

terraform destroy -auto-approve \
                  -var="api_token=$(vault kv get -field API_TOKEN kv/proxmox/api)" \
                  -var="proxmox_data=${TF_PROXMOX_DATA}" \
                  -out "${TF_PLAN}"

