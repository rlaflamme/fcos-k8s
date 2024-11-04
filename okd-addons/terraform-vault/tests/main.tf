terraform {
  required_version = ">= 1.0"
}

locals {
  vault_data = yamldecode(var.vault_data)
}

resource "null_resource" "test_k8s_authentication" {
  for_each = { for role in local.vault_data.vault.auth_k8s_roles : role.name => role }

  provisioner "local-exec" {
    command = "vault write auth/${each.value.path}/login role=${each.value.name} jwt=${var.vault_k8s_auth_token_reviewer_jwt}"
  }
}
