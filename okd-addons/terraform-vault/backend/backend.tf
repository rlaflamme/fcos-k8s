
terraform {
  backend "local" {
    path                  = "/mnt/nfs/terraform-okd4-tfstate/terraform-vault/backend/terraform.tfstate"
  }
}
