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

if [ "${GITLAB_TOKEN:-x}" == "x" ]; then
  echo ""
  echo "!!Missing GITLAB_TOKEN environment variable!!"
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

TF_PLAN="terraform-flux.tfplan"
TF_AWS_PROFILE="terraform-flux-tfstate"
TF_STATE_KEY="terraform-flux-tfstate/okd-addons/terraform-flux/terraform.tfstate"
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

terraform destroy \
              -var="gitlab_token=${GITLAB_TOKEN}" \
              -var="env_name=${ENV_NAME}" \
              -var-file terraform-vars/${ENV_NAME}.tfvars 

