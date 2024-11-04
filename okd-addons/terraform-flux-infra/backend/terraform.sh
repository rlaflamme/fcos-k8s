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

if [[ "${VAULT_TOKEN:-x}" == "x" ]]; then
  echo ""
  echo "!!Missing VAULT_TOKEN environment variable!!"
  echo ""
  exit 1
fi

TF_PLAN="terraform-okd4.tfplan"

terraform -version -json | jq

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

source ./credentials.sh

terraform init -upgrade

terraform plan -out "${TF_PLAN}"

terraform apply "${TF_PLAN}"
