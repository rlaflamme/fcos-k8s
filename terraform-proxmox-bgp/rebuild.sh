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

#ansible -i proxmox.lan, all -m shell -a 'pveum aclmod / -token 'terraform-prov@pam!mytoken' -role TerraformProv && pveum aclmod / -user terraform-prov@pam -role TerraformProv && pveum role modify TerraformProv -privs "SDN.Use, VM.Config.Disk, VM.Config.Options, VM.Config.Network, Datastore.Allocate, VM.Config.CDROM, Pool.Allocate, VM.Config.HWType, VM.Config.CPU, Datastore.AllocateSpace, VM.Config.Memory, VM.Config.Cloudinit, VM.Allocate, VM.Monitor, VM.Audit, Pool.Audit, Datastore.AllocateTemplate, Datastore.Audit, Group.Allocate, Mapping.Audit, Mapping.Modify, Mapping.Use, Permissions.Modify, Realm.Allocate, Realm.AllocateUser, SDN.Allocate, SDN.Audit, SDN.Use, Sys.Audit, Sys.Console, Sys.Incoming, Sys.Modify, Sys.PowerMgmt, Sys.Syslog, User.Modify, VM.Backup, VM.Clone, VM.Console, VM.Migrate, VM.PowerMgmt, VM.Snapshot, VM.Snapshot.Rollback"'

ansible -i proxmox.lan, all -m shell -a 'pveum aclmod / -token 'terraform-prov@pam\!mytoken' -role PVEAdmin && pveum aclmod / -user terraform-prov@pam -role PVEAdmin'

terraform destroy -auto-approve \
                  -var="api_token=$(vault kv get -field API_TOKEN kv/proxmox/api)" \
                  -var="proxmox_data=${TF_PROXMOX_DATA}"
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
              -out "${TF_PLAN}" -lock=false

clear
echo

terraform apply "${TF_PLAN}"

echo

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

K8S_HOSTS="okd4-control-plane-1 okd4-control-plane-2 okd4-control-plane-3 okd4-worker-1 okd4-worker-2 okd4-worker-3"
for k8s_host in $K8S_HOSTS; do ssh -o StrictHostKeyChecking=accept-new core@$k8s_host "sudo coreos-installer install /dev/sda -i /etc/target.ign;sudo reboot"; done

echo ""

remove_ssh_keys

echo
read -r -s -n 1 -p "Wait for the last node to be up and running and press any key"

for k8s_host in $K8S_HOSTS; do ssh -o StrictHostKeyChecking=accept-new core@$k8s_host "date"; done

echo ""
