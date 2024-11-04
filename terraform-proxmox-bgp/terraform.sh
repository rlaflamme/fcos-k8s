#!/usr/bin/sh

if [ "${VAULT_TOKEN:-x}" == "x" ]; then
  echo ""
  echo "!!Missing VAULT_TOKEN environment variable!!"
  echo ""
  exit 1
fi

TF_LOG_LEVEL=INFO
TF_PLAN="proxmox-okd4"
TF_PROXMOX_DATA="terraform-vars/production.yaml"

source ~/.private/proxmox

ansible -i proxmox.lan, all -m shell -a "pveum aclmod / -token 'terraform-prov@pam!mytoken' -role TerraformProvrraformProv"
