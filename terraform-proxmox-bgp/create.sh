#!/usr/bin/sh

if [ "${VAULT_TOKEN:-x}" == "x" ]; then
  echo ""
  echo "!!Missing VAULT_TOKEN environment variable!!"
  echo ""
  exit 1
fi

remove_ssh_key()
{
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1" 2> /dev/null
}

remove_ssh_keys()
{
  echo "Removing ssh known hosts..."

  remove_ssh_key "$(dig + short okd4-control-plane-1)"
  remove_ssh_key "$(dig + short okd4-control-plane-2)"
  remove_ssh_key "$(dig + short okd4-worker-1)"
  remove_ssh_key "$(dig + short okd4-worker-2)"
  remove_ssh_key "$(dig + short okd4-worker-3)"

  remove_ssh_key "okd4-control-plane-1"
  remove_ssh_key "okd4-control-plane-2"
  remove_ssh_key "okd4-control-plane-3"
  remove_ssh_key "okd4-worker-1"
  remove_ssh_key "okd4-worker-2"
  remove_ssh_key "okd4-worker-3"
}

remove_ssh_keys

echo ""

TF_LOG_LEVEL=INFO
TF_PLAN="proxmox-okd4"
TF_PROXMOX_DATA="./terraform-vars/production.yaml"

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

TF_LOG=$TF_LOG_LEVEL terraform init

terraform plan \
               -var="api_token=$(vault kv get -field API_TOKEN kv/proxmox/api)" \
               -var="proxmox_data=${TF_PROXMOX_DATA}" \
               -out "${TF_PLAN}"

echo
read -r -s -n 1 -p "Press any key to apply plan [${TF_PLAN}] ..."

clear
echo

terraform apply "${TF_PLAN}" 
