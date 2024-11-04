# #------------------------------------------------------------------------------#
# # Keycloak Basics
# #------------------------------------------------------------------------------#

# resource "keycloak_realm" "realm_test" {
#   realm   = "okd4-test"
#   enabled = true
# }

# #------------------------------------------------------------------------------#
# # Keycloak Vault OIDC Client
# #------------------------------------------------------------------------------#

# resource "keycloak_openid_client" "weave_gitops" {
#   realm_id      = keycloak_realm.realm_test.id
#   client_id     = "weave-gitops"
#   client_secret = "test"

#   name                  = "weave-gitops"
#   enabled               = true
#   standard_flow_enabled = true
#   access_type           = "CONFIDENTIAL"
#   valid_redirect_uris = [
#     "https://weave-gitops.apps.lab.okd.local/oauth2/callback",
#   ]
#   login_theme = "keycloak"

# }

# resource "keycloak_openid_client_default_scopes" "weave_gitops" {
#   realm_id  = keycloak_realm.realm_test.id
#   client_id = keycloak_openid_client.weave_gitops.id

#   default_scopes = [
#     "email",
#     keycloak_openid_client_scope.groups.name,
#     keycloak_openid_client_scope.username.name,
#   ]
# }


# #------------------------------------------------------------------------------#
# # Keycloak wave-gitops OIDC
# #------------------------------------------------------------------------------#

# resource "keycloak_openid_client_scope" "groups" {
#   realm_id               = keycloak_realm.realm_test.id
#   name                   = "groups"
#   include_in_token_scope = true
#   gui_order              = 1
# }

# resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
#   realm_id        = keycloak_realm.realm_test.id
#   client_scope_id = keycloak_openid_client_scope.groups.id
#   name            = "group-membership-mapper"
#   full_path       = false

#   claim_name = "groups"
# }

# resource "keycloak_openid_client_scope" "username" {
#   realm_id               = keycloak_realm.realm_test.id
#   name                   = "username"
#   include_in_token_scope = true
#   gui_order              = 1
# }

# resource "keycloak_openid_user_attribute_protocol_mapper" "username" {
#   realm_id        = keycloak_realm.realm_test.id
#   client_scope_id = keycloak_openid_client_scope.username.id
#   name            = "user-attribute-mapper"
#   user_attribute  = "username"

#   claim_name = "username"
# }


# #------------------------------------------------------------------------------#
# # Keycloak LDAP User Federation
# #------------------------------------------------------------------------------#

# resource "keycloak_ldap_user_federation" "ldap_user_federation_test" {
#   name     = local.keycloak_data.keycloak.ldap_user_federation.name
#   realm_id = keycloak_realm.realm_test.id
#   enabled  = true

#   username_ldap_attribute = "uid"
#   rdn_ldap_attribute      = "uid"
#   uuid_ldap_attribute     = "entryUUID"
#   user_object_classes = [
#     "inetOrgPerson",
#     "organizationalPerson"
#   ]
#   connection_url     = local.keycloak_data.keycloak.ldap_user_federation.connection_url
#   users_dn           = local.keycloak_data.keycloak.ldap_user_federation.users_dn
#   bind_dn            = local.keycloak_data.keycloak.ldap_user_federation.bind_dn
#   bind_credential    = data.vault_generic_secret.openldap.data["ldap_password"]
#   search_scope       = "SUBTREE"
#   connection_timeout = "5s"
#   read_timeout       = "10s"
# }

# resource "keycloak_ldap_group_mapper" "ldap_group_mapper_test" {
#   realm_id                = keycloak_realm.realm_test.id
#   ldap_user_federation_id = keycloak_ldap_user_federation.ldap_user_federation_test.id
#   name                    = "group-mapper"

#   ldap_groups_dn            = local.keycloak_data.keycloak.ldap_user_federation.groups_dn
#   group_name_ldap_attribute = "cn"
#   group_object_classes = [
#     "groupOfUniqueNames"
#   ]
#   membership_attribute_type      = "DN"
#   membership_ldap_attribute      = "uniquemember"
#   membership_user_ldap_attribute = "uid"
#   memberof_ldap_attribute        = "memberOf"
# }