

### kubernetes config-clusters unmanaged secret
resource "kubernetes_namespace" "flux_system" {

  metadata {
    name = "flux-system"
  }

}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [kubernetes_namespace.flux_system]

  create_duration = "30s"

  triggers = {
    # This sets up a proper dependency on the RAM association
    flux_system_namespace = kubernetes_namespace.flux_system.metadata[0].name
  }
}

resource "kubernetes_config_map" "public_pfsense_bundle" {
  depends_on = [time_sleep.wait_30_seconds]

  lifecycle {
    ignore_changes = all
  }

  metadata {
    name      = "public-pfsense-bundle"
    namespace = "flux-system"

  }

  data = {
    "ca-bundle.crt" = file("${path.module}/assets/${var.env_name}/pfsense-lab-okd-local-ca-bundle.pem")
  }

}

### kubernetes config-clusters unmanaged secret
resource "kubernetes_secret" "config_infra" {

  depends_on = [time_sleep.wait_30_seconds]

  lifecycle {
    ignore_changes = all
  }

  metadata {
    name      = "config-infra"
    namespace = "flux-system"
  }

  data = {
    username = local.flux_bootstrap_data.flux_bootstrap.gitlab.projects.flux_bootstrap.tokens.config_infra_token_reader
    password = data.vault_generic_secret.flux.data[local.flux_bootstrap_data.flux_bootstrap.vault.secrets.flux.keys.config_infra_token_reader]
  }

  type = "Opaque"
}


### kubernetes config-apps unmanaged secret
resource "kubernetes_secret" "config_apps" {

  depends_on = [time_sleep.wait_30_seconds]

  lifecycle {
    ignore_changes = all
  }

  metadata {
    name      = "config-apps"
    namespace = "flux-system"
  }

  data = {
    username = local.flux_bootstrap_data.flux_bootstrap.gitlab.projects.flux_bootstrap.tokens.config_apps_token_writer
    password = data.vault_generic_secret.flux.data[local.flux_bootstrap_data.flux_bootstrap.vault.secrets.flux.keys.config_apps_token_writer]
  }

  type = "Opaque"
}

