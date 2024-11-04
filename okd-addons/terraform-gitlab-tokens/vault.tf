### vault integration

# terraform secret
data "vault_generic_secret" "terraform" {
  path = local.gitlab_tokens_data.gitlab_tokens.vault.secrets.terraform.path
}

# flux secret
resource "vault_generic_secret" "flux" {
  path = local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.path
  data_json = jsonencode({
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.flux_system_token_writer)           = gitlab_project_access_token.gitlab_project_flux_system_token_writer.token
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.flux_system_token_reader)           = gitlab_project_access_token.gitlab_project_flux_system_token_reader.token
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.config_apps_token_writer)           = gitlab_project_access_token.gitlab_project_config_apps_token_writer.token
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.config_infra_token_reader)          = gitlab_project_access_token.gitlab_project_config_infra_token_reader.token
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.helm_token_reader)                  = gitlab_group_access_token.gitlab_group_helm_token_reader.token
    (local.gitlab_tokens_data.gitlab_tokens.vault.secrets.flux.keys.gitops_tekton_welcome_token_reader) = gitlab_group_access_token.gitlab_group_gitops_tekton_welcome_token_reader.token
  })
}
