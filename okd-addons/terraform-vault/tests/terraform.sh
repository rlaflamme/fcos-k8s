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

TF_NAMESPACE="hashicorp"
TF_VAULT_SECRET_NAME="vault-token"
TF_SA_CA_CRT=$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.certificate-authority-data}' | base64 --decode)
TF_SA_JWT_TOKEN=$(kubectl get secret $TF_VAULT_SECRET_NAME -n $TF_NAMESPACE -o jsonpath="{.data.token}" | base64 --decode; echo)
TF_K8S_HOST=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
TF_PLAN="terraform-okd4.tfplan"
TF_LOG_LEVEL=INFO

TF_VAULT_DATA=$(yq ea '. as $item ireduce ({}; . *+ $item )' ../assets/*/vault.yaml)

terraform -version -json | jq

echo
echo Checking for Terraform unused declarations
tflint --enable-rule=terraform_unused_declarations
echo
terraform get -update=true
echo

rm -f terraform.tfstate

terraform init -upgrade

terraform plan -var="vault_k8s_auth_token_reviewer_jwt=${TF_SA_JWT_TOKEN}" \
               -var="vault_data=${TF_VAULT_DATA}" \
               -out "${TF_PLAN}"

terraform apply -parallelism=1 "${TF_PLAN}"
