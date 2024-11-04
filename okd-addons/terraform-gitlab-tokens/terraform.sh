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

TF_GITLAB_TOKENS_DATA="./terraform-vars/production.yaml"
TF_PLAN="terraform-flux-gitlab-tokens.tfplan"
TF_LOG_LEVEL=INFO

#TF_VAULT_DATA=$(yq ea '. as $item ireduce ({}; . *+ $item )' ./assets/*/vault.yaml)

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
              -var="gitlab_access_token_expiration_date=$(date '+%F' -d '+365 days')" \
              -var="gitlab_tokens_data=${TF_GITLAB_TOKENS_DATA}" \
              -out "${TF_PLAN}" -lock=false

echo
read -r -s -n 1 -p "Press any key to apply plan [${TF_PLAN}] ..."

clear
echo

terraform apply "${TF_PLAN}" 
