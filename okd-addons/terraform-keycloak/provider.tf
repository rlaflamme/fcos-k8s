terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

provider "vault" {
  address      = local.keycloak_data.keycloak.vault.server_address
  ca_cert_file = local.keycloak_data.keycloak.config.ca_cert_file
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = local.keycloak_user
  password  = data.vault_generic_secret.keycloak.data["admin-password"]
  base_path = ""
  // see docker-compose.yml
  url = local.keycloak_data.keycloak.address
}
