
# terraform {
#   backend "s3" {
#     bucket         = "terraform-flux-infra-tfstate"
#     encrypt        = true
#     key            = "terraform.tfstate"
#     region         = "ca-central-1"
#     dynamodb_table = "terraform-flux-infra-tfstate"
#   }
# }

terraform {
  backend "local" {
    path = "/mnt/nfs/terraform-flux-tfstate/terraform-flux-infra/backend/terraform.tfstate"
  }
}
