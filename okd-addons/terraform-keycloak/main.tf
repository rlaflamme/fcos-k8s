terraform {
  required_version = ">= 1.0"
}

locals {
  keycloak_data = yamldecode(file(var.keycloak_data))
  keycloak_user = "admin"
}
