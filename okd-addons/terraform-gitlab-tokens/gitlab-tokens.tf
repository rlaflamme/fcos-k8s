### gitlab flux-bootstrap access token reader
resource "gitlab_project_access_token" "gitlab_project_flux_system_token_reader" {
  project      = data.gitlab_project.flux_bootstrap.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_reader.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_reader.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_reader.scopes
}

### gitlab flux-bootstrap access token writer
resource "gitlab_project_access_token" "gitlab_project_flux_system_token_writer" {
  project      = data.gitlab_project.flux_bootstrap.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_writer.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_writer.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.tokens.flux_system_token_writer.scopes
}

### gitlab config-infra access token
resource "gitlab_project_access_token" "gitlab_project_config_infra_token_reader" {
  project      = data.gitlab_project.config_infra.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_infra.tokens.config_infra_token_reader.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_infra.tokens.config_infra_token_reader.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_infra.tokens.config_infra_token_reader.scopes
}

### gitlab config-apps access token
resource "gitlab_project_access_token" "gitlab_project_config_apps_token_writer" {
  project      = data.gitlab_project.config_apps.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_apps.tokens.config_apps_token_writer.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_apps.tokens.config_apps_token_writer.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_apps.tokens.config_apps_token_writer.scopes
}

### gitlab helm group acces token
resource "gitlab_group_access_token" "gitlab_group_helm_token_reader" {
  group        = data.gitlab_group.helm.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.helm.tokens.helm_token_reader.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.helm.tokens.helm_token_reader.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.helm.tokens.helm_token_reader.scopes
}

### gitlab gitops-tekton-welcome group acces token
resource "gitlab_group_access_token" "gitlab_group_gitops_tekton_welcome_token_reader" {
  group        = data.gitlab_group.gitops_tekton_welcome.id
  name         = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.gitops_tekton_welcome.tokens.gitops_tekton_welcome_token_reader.name
  expires_at   = var.gitlab_access_token_expiration_date
  access_level = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.gitops_tekton_welcome.tokens.gitops_tekton_welcome_token_reader.access_level
  scopes       = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.gitops_tekton_welcome.tokens.gitops_tekton_welcome_token_reader.scopes
}
