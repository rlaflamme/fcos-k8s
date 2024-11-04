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

export VAULT_ADDR="https://okd4-vault-1.lab.okd.local:8200"
export VAULT_SKIP_VERIFY="true"

TF_SA_CA_CRT=""
TF_SA_JWT_TOKEN=""
TF_K8S_HOST=""

terraform -version -json | jq

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

source ./credentials.sh

terraform destroy -var="kubernetes_host=${TF_K8S_HOST}" \
                  -var="kubernetes_ca_cert=${TF_SA_CA_CRT}" \
                  -var="vault_k8s_auth_token_reviewer_jwt=${TF_SA_JWT_TOKEN}" \
                  -auto-approve

