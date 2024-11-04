#------------------------------------------------------------------------------#
# vault secrets
#------------------------------------------------------------------------------#

data "vault_generic_secret" "keycloak" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak.path
}

data "vault_generic_secret" "keycloak_oidc_clients_apisix" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_apisix.path
}

data "vault_generic_secret" "keycloak_oidc_clients_vault" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_vault.path
}

data "vault_generic_secret" "keycloak_oidc_clients_weave_gitops" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_weave_gitops.path
}

data "vault_generic_secret" "keycloak_oidc_clients_kong" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_kong.path
}

data "vault_generic_secret" "keycloak_oidc_clients_kuma" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_kuma.path
}

data "vault_generic_secret" "keycloak_oidc_clients_kyverno" {
  path = local.keycloak_data.keycloak.vault.secrets.keycloak_oidc_clients_kyverno.path
}

data "vault_generic_secret" "openldap" {
  path = local.keycloak_data.keycloak.vault.secrets.openldap.path
}


#------------------------------------------------------------------------------#
# OIDC client
#------------------------------------------------------------------------------#

resource "vault_identity_oidc_key" "keycloak_provider_key" {
  name      = "keycloak"
  algorithm = "RS256"
}

resource "vault_jwt_auth_backend" "keycloak" {
  path               = "oidc"
  type               = "oidc"
  default_role       = "default"
  oidc_discovery_url = format("${local.keycloak_data.keycloak.address}/realms/%s", keycloak_realm.realm.id)
  oidc_client_id     = keycloak_openid_client.vault.client_id
  oidc_client_secret = keycloak_openid_client.vault.client_secret

  tune {
    audit_non_hmac_request_keys  = []
    audit_non_hmac_response_keys = []
    default_lease_ttl            = "1h"
    listing_visibility           = "unauth"
    max_lease_ttl                = "1h"
    passthrough_request_headers  = []
    token_type                   = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "default" {
  backend       = vault_jwt_auth_backend.keycloak.path
  role_name     = "default"
  token_ttl     = 3600
  token_max_ttl = 3600

  bound_audiences = [keycloak_openid_client.vault.client_id]
  user_claim      = "preferred_username"
  claim_mappings = {
    preferred_username = "username"
    email              = "email"
  }
  role_type             = "oidc"
  allowed_redirect_uris = ["${local.keycloak_data.keycloak.vault.address}/ui/vault/auth/oidc/oidc/callback", "http://localhost:8250/oidc/callback"]
  groups_claim          = "groups"
  oidc_scopes           = ["openid"]
}

#------------------------------------------------------------------------------#
# Vault policies
#------------------------------------------------------------------------------#
module "dev" {
  source                       = "./external_group"
  external_accessor            = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "dev"
      rules = [
        {
          path         = "/secret/*"
          capabilities = ["read", "list"]
        }
      ]
    }
  ]
}

module "secops" {
  source                       = "./external_group"
  external_accessor            = vault_jwt_auth_backend.keycloak.accessor
  vault_identity_oidc_key_name = vault_identity_oidc_key.keycloak_provider_key.name
  groups = [
    {
      group_name = "secops"
      rules = [
        {
          path         = "/secret/*"
          capabilities = ["read", "list", "create", "update", "delete"]
        }
      ]
    }
  ]
}
