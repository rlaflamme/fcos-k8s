#!/usr/bin/env bash
set -o errexit -u

if [ "${VAULT_TOKEN:-x}" == "x" ]; then
  echo ""
  echo "!!Missing VAULT_TOKEN environment variable!!"
  echo ""
  exit 1
fi

if [ $# -eq 0 ]; then
  echo ""
  echo "!!Missing environment name!!"
  echo ""
  exit 1
fi

ENV_NAME=$1

TF_KEYCLOAK_DATA="./terraform-vars/production.yaml"
TF_PLAN="terraform-keycloak.tfplan"
TF_LOG_LEVEL=DEBUG

terraform -version -json | jq

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

TF_LOG=$TF_LOG_LEVEL terraform init \
    -migrate-state

TF_LOG=$TF_LOG_LEVEL terraform init \
    -upgrade

terraform plan \
              -var="keycloak_data=${TF_KEYCLOAK_DATA}" \
              -out "${TF_PLAN}" -lock=false

echo
read -r -s -n 1 -p "Press any key to apply plan [${TF_PLAN}] ..."

clear
echo

terraform apply "${TF_PLAN}" 
