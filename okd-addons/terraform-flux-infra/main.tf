terraform {
  required_version = ">= 1.0"
}

locals {
  flux_bootstrap_data = yamldecode(file(var.flux_bootstrap_data))
}

### flux bootstrap
resource "flux_bootstrap_git" "cluster_deployment" {

  depends_on = [kubernetes_config_map.public_pfsense_bundle]

  path                   = local.flux_bootstrap_data.flux_bootstrap.flux.target_path
  kustomization_override = file("${path.module}/assets/${var.env_name}/kustomization.yaml")
  components_extra       = ["image-reflector-controller", "image-automation-controller"]
}

