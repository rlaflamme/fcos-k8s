### gitlab project flux-bootstrap
data "gitlab_project" "flux_bootstrap" {
  path_with_namespace = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.flux_bootstrap.path
}

### gitlab project flux-infra alias config_infra
data "gitlab_project" "config_infra" {
  path_with_namespace = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_infra.path
}

### gitlab project flux-infra alias config_apps
data "gitlab_project" "config_apps" {
  path_with_namespace = local.gitlab_tokens_data.gitlab_tokens.gitlab.projects.config_apps.path
}

### gitlab helm group
data "gitlab_group" "helm" {
  full_path = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.helm.path
}

### gitlab gitops-tekton-welcome group acces token
data "gitlab_group" "gitops_tekton_welcome" {
  full_path = local.gitlab_tokens_data.gitlab_tokens.gitlab.groups.gitops_tekton_welcome.path
}

