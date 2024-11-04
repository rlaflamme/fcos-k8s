#------------------------------------------------------------------------------#
# Keycloak Basics
#------------------------------------------------------------------------------#

resource "keycloak_realm" "realm" {
  realm   = local.keycloak_data.keycloak.realm_name
  enabled = true
}

#------------------------------------------------------------------------------#
# Client Scopes
#------------------------------------------------------------------------------#

# groups
resource "keycloak_openid_client_scope" "groups" {
  realm_id               = keycloak_realm.realm.id
  name                   = "groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "group-membership-mapper"
  full_path       = false

  claim_name = "groups"
}


# username
resource "keycloak_openid_client_scope" "username" {
  realm_id               = keycloak_realm.realm.id
  name                   = "username"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_user_attribute_protocol_mapper" "username" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.username.id
  name            = "username"
  user_attribute  = "username"

  claim_name = "preferred_username"
}

# kong_api_access
resource "keycloak_openid_client_scope" "kong_api_access" {
  realm_id               = keycloak_realm.realm.id
  name                   = "kong_api_access"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_generic_role_mapper" "kong_api_access" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.kong_api_access.id
  role_id         = keycloak_role.kong_role.id
}


#------------------------------------------------------------------------------#
# Keycloak Vault OIDC - vault
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "vault" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "vault"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_vault.data["vault.client_secret"]

  name                  = "vault"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "${local.keycloak_data.keycloak.vault.address}/ui/vault/auth/oidc/oidc/callback"
  ]
  login_theme = "keycloak"
}

resource "keycloak_openid_client_default_scopes" "vault" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.vault.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.username.name,
  ]
}

resource "keycloak_group" "secops" {
  realm_id = keycloak_realm.realm.id
  name     = "secops"
}

resource "keycloak_role" "secops_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "secops_role"
  description = "Secops role"
}

resource "keycloak_group_roles" "secops_role" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.secops.id

  role_ids = [
    keycloak_role.secops_role.id,
  ]
}

resource "keycloak_group" "dev" {
  realm_id = keycloak_realm.realm.id
  name     = "dev"
}

resource "keycloak_role" "dev_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "dev_role"
  description = "Dev/Reader role"
}

resource "keycloak_group_roles" "dev_role" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.dev.id

  role_ids = [
    keycloak_role.dev_role.id,
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "vault" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.vault.id
  name      = "group-membership-mapper"
  full_path = false

  claim_name = "groups"
}


#------------------------------------------------------------------------------#
# Keycloak APISIX OIDC - secureapp
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "secureapp" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "secureapp"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_apisix.data["secureapp.client_secret"]

  name                  = "secureapp"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://secureapp.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://secureapp.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"
}

resource "keycloak_openid_client_default_scopes" "secureapp" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.secureapp.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.kong_api_access.name,
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "secureapp" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.secureapp.id
  name      = "group-membership-mapper"
  full_path = false

  claim_name = "groups"
}


#------------------------------------------------------------------------------#
# Keycloak APISIX OIDC - MyClient
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "myclient" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "myclient"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_apisix.data["myclient.client_secret"]

  name                  = "myclient"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://my-secure-app.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://my-secure-app.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"
}

resource "keycloak_openid_client_default_scopes" "myclient" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.myclient.id

  default_scopes = [
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.kong_api_access.name,
  ]
}

resource "keycloak_openid_group_membership_protocol_mapper" "myclient" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.myclient.id
  name      = "group-membership-mapper"
  full_path = false

  claim_name = "groups"
}

resource "keycloak_role" "kong_role" {
  realm_id    = keycloak_realm.realm.id
  name        = "kong_role"
  description = "Kong Role"
}

resource "keycloak_group" "kongers" {
  realm_id = keycloak_realm.realm.id
  name     = "kongers"
}

resource "keycloak_group_roles" "kong_role" {
  realm_id = keycloak_realm.realm.id
  group_id = keycloak_group.kongers.id

  role_ids = [
    keycloak_role.kong_role.id,
  ]
}


#------------------------------------------------------------------------------#
# Keycloak weave-gitops OIDC -- weave-gitops
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "weave_gitops" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "weave-gitops"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_weave_gitops.data["weave_gitops.client_secret"]

  name                  = "weave-gitops"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://weave-gitops.apps.lab.okd.local/callback",
    "https://weave-gitops2.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://weave-gitops.apps.lab.okd.local/logout",
    "https://weave-gitops2.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"

}

resource "keycloak_openid_client_default_scopes" "weave_gitops" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.weave_gitops.id

  default_scopes = [
    "email",
    "profile",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.username.name,
  ]
}


#------------------------------------------------------------------------------#
# Keycloak kong OIDC -- kong
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "kong" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "kong"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_kong.data["kong.client_secret"]

  name                  = "kong"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://kong-manager.apps.lab.okd.local/callback",
    "https://kong-admin.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://kong-manager.apps.lab.okd.local/logout",
    "https://kong-admin.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"

}

resource "keycloak_openid_client_default_scopes" "kong" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.kong.id

  default_scopes = [
    "email",
    "profile",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.username.name,
  ]
}


#------------------------------------------------------------------------------#
# Keycloak kuma OIDC -- kuma
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "kuma" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "kuma"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_kuma.data["kuma.client_secret"]

  name                  = "kuma"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://kuma-control-plane.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://kuma-control-plane.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"

}

resource "keycloak_openid_client_default_scopes" "kuma" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.kuma.id

  default_scopes = [
    "email",
    "profile",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.username.name,
  ]
}


#------------------------------------------------------------------------------#
# Keycloak kyverno-policy-reporter OIDC -- kyverno
#------------------------------------------------------------------------------#

resource "keycloak_openid_client" "kyverno_policy_reporter" {
  realm_id      = keycloak_realm.realm.id
  client_id     = "kyverno-policy-reporter"
  client_secret = data.vault_generic_secret.keycloak_oidc_clients_kyverno.data["policy-reporter.client_secret"]

  name                  = "kyverno-policy-reporter"
  enabled               = true
  standard_flow_enabled = true
  access_type           = "CONFIDENTIAL"
  valid_redirect_uris = [
    "https://policy-reporter.apps.lab.okd.local/callback",
  ]
  valid_post_logout_redirect_uris = [
    "https://policy-reporter.apps.lab.okd.local/logout",
  ]
  login_theme = "keycloak"

}

resource "keycloak_openid_client_default_scopes" "kyverno_policy_reporter" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.kyverno_policy_reporter.id

  default_scopes = [
    "email",
    "profile",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.username.name,
  ]
}


#------------------------------------------------------------------------------#
# Keycloak LDAP User Federation
#------------------------------------------------------------------------------#

resource "keycloak_ldap_user_federation" "ldap_user_federation" {
  name     = local.keycloak_data.keycloak.ldap_user_federation.name
  realm_id = keycloak_realm.realm.id
  enabled  = true

  username_ldap_attribute = "uid"
  rdn_ldap_attribute      = "uid"
  uuid_ldap_attribute     = "entryUUID"
  user_object_classes = [
    "inetOrgPerson",
    "organizationalPerson"
  ]
  connection_url     = local.keycloak_data.keycloak.ldap_user_federation.connection_url
  users_dn           = local.keycloak_data.keycloak.ldap_user_federation.users_dn
  bind_dn            = local.keycloak_data.keycloak.ldap_user_federation.bind_dn
  bind_credential    = data.vault_generic_secret.openldap.data["ldap_password"]
  search_scope       = "SUBTREE"
  connection_timeout = "5s"
  read_timeout       = "10s"
}

resource "keycloak_ldap_group_mapper" "ldap_group_mapper" {
  realm_id                = keycloak_realm.realm.id
  ldap_user_federation_id = keycloak_ldap_user_federation.ldap_user_federation.id
  name                    = "group-mapper"

  ldap_groups_dn            = local.keycloak_data.keycloak.ldap_user_federation.groups_dn
  group_name_ldap_attribute = "cn"
  group_object_classes = [
    "groupOfUniqueNames"
  ]
  membership_attribute_type      = "DN"
  membership_ldap_attribute      = "uniquemember"
  membership_user_ldap_attribute = "uid"
  memberof_ldap_attribute        = "memberOf"
}