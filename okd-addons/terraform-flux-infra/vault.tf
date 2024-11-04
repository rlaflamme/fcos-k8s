### vault integration

# flux secret
data "vault_generic_secret" "flux" {
  path = local.flux_bootstrap_data.flux_bootstrap.vault.secrets.flux.path
}
