
terraform {
  backend "local" {
    path                  = "/mnt/nfs/terraform-flux-tfstate/terraform-flux-infra/backend/terraform.tfstate"
  }
}
