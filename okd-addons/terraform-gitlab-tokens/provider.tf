terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=3.19.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = ">=16.3.0"
    }
  }
}

provider "vault" {
  address      = local.gitlab_tokens_data.gitlab_tokens.vault.address
  ca_cert_file = local.gitlab_tokens_data.gitlab_tokens.config.ca_cert_file
}

provider "gitlab" {
  base_url = local.gitlab_tokens_data.gitlab_tokens.gitlab.https_host
  token    = data.vault_generic_secret.terraform.data[local.gitlab_tokens_data.gitlab_tokens.vault.secrets.terraform.keys.tf_flux_token_writer]
}
