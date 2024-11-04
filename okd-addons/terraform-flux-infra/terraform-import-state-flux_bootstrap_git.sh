#!/usr/bin/env bash
set -o errexit -u

unset AWS_ACCESS_KEY
unset AWS_SECRET_ACCESS_KEY

cleanup() {
    echo "Cleaning stuff up..."
    unset AWS_ACCESS_KEY
    unset AWS_SECRET_ACCESS_KEY
    exit
}

trap cleanup EXIT INT TERM

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

export VAULT_SKIP_VERIFY="true"

TF_PLAN="terraform-flux-infra.tfplan"
TF_AWS_PROFILE="terraform-flux-infra-tfstate"
TF_STATE_KEY="terraform-flux-infra-tfstate/okd-addons/terraform-flux-infra/terraform.tfstate"
TF_LOG_LEVEL=INFO

#TF_VAULT_DATA=$(yq ea '. as $item ireduce ({}; . *+ $item )' ./assets/*/vault.yaml)

terraform -version -json | jq

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

source ./credentials.sh

TF_LOG=$TF_LOG_LEVEL terraform init \
    -migrate-state \
    -backend-config "key=${TF_STATE_KEY}" \
    -backend-config "profile=${TF_AWS_PROFILE}" -lock=false

TF_LOG=$TF_LOG_LEVEL terraform init \
    -upgrade \
    -backend-config "key=${TF_STATE_KEY}" \
    -backend-config "profile=${TF_AWS_PROFILE}" -lock=false

terraform import \
              -var="gitlab_access_token_expiration_date=$(date '+%F' -d '+365 days')" \
              -var="env_name=${ENV_NAME}" \
              -var-file terraform-vars/${ENV_NAME}.tfvars \
              flux_bootstrap_git.cluster_deployment \
              flux-system 
