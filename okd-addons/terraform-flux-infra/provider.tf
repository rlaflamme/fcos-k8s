terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=4.3.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">=1.3.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">=17.2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.31.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.0"
    }
  }
}

provider "vault" {
  address      = local.flux_bootstrap_data.flux_bootstrap.vault.address
  ca_cert_file = local.flux_bootstrap_data.flux_bootstrap.config.ca_cert_file
}

provider "flux" {
  kubernetes = {
    config_path = local.flux_bootstrap_data.flux_bootstrap.kubernetes.client_config
  }
  git = {
    url    = local.flux_bootstrap_data.flux_bootstrap.gitlab.https_host_project_flux_bootstrap
    branch = local.flux_bootstrap_data.flux_bootstrap.gitlab.branch_name
    http = {
      username              = local.flux_bootstrap_data.flux_bootstrap.gitlab.projects.flux_bootstrap.tokens.flux_system_token_writer
      password              = data.vault_generic_secret.flux.data[local.flux_bootstrap_data.flux_bootstrap.vault.secrets.flux.keys.flux_system_token_writer]
      certificate_authority = file(local.flux_bootstrap_data.flux_bootstrap.config.ca_cert_file)
    }
  }
}

provider "gitlab" {
  base_url = local.flux_bootstrap_data.flux_bootstrap.gitlab.https_host
  token    = data.vault_generic_secret.flux.data[local.flux_bootstrap_data.flux_bootstrap.vault.secrets.flux.keys.flux_system_token_writer]
}

provider "kubernetes" {
  config_path = local.flux_bootstrap_data.flux_bootstrap.kubernetes.client_config
}
