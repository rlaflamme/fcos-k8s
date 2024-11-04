terraform {
  required_version = ">= 1.0"
}

locals {
  gitlab_tokens_data = yamldecode(file(var.gitlab_tokens_data))
}