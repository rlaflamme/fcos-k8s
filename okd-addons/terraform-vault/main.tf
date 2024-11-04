terraform {
  required_version = ">= 1.0"
}

locals {
  vault_data = yamldecode(var.vault_data)

}

resource "vault_policy" "okd4" {
  for_each = { for policy in local.vault_data.vault.policies : policy.name => policy }

  name   = each.value.name
  policy = <<EOT
%{for path in each.value.path~}
path "${path.name}" {
  capabilities = [%{for i, capability in path.capabilities}"${capability}"%{if i < length(path.capabilities) - 1}, %{endif}%{endfor~}]
}
%{endfor~}
EOT
}

resource "vault_auth_backend" "okd4" {
  for_each = toset(local.vault_data.vault.auth_k8s_roles[*].path)

  type = "kubernetes"
  path = each.key
}

resource "vault_kubernetes_auth_backend_role" "okd4" {
  for_each = { for role in local.vault_data.vault.auth_k8s_roles : role.name => role }

  backend                          = each.value.path
  role_name                        = each.value.name
  bound_service_account_names      = each.value.bound_sa_names
  bound_service_account_namespaces = each.value.bound_sa_namespaces
  token_policies                   = each.value.token_policies
  token_ttl                        = "86400"

  depends_on = [vault_auth_backend.okd4]
}

resource "vault_kubernetes_auth_backend_config" "okd4" {
  for_each = toset(local.vault_data.vault.auth_k8s_roles[*].path)

  backend            = each.key
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.vault_k8s_auth_token_reviewer_jwt

  depends_on = [vault_auth_backend.okd4]
}

resource "vault_pki_secret_backend_role" "okd4" {
  for_each = { for role in local.vault_data.vault.pki_roles : role.name => role }

  backend                     = each.value.backend
  name                        = each.value.name
  ttl                         = 15768000
  max_ttl                     = 15768000
  allow_ip_sans               = true
  key_type                    = "rsa"
  key_bits                    = 4096
  allowed_domains             = each.value.allowed_domains
  allow_subdomains            = true
  no_store                    = true
  generate_lease              = false
  allow_localhost             = false
  allow_bare_domains          = true
  allow_glob_domains          = false
  allow_any_name              = false
  allow_wildcard_certificates = true
  enforce_hostnames           = true
  server_flag                 = true
  client_flag                 = false
  use_csr_common_name         = true
  use_csr_sans                = true
  require_cn                  = true
}
