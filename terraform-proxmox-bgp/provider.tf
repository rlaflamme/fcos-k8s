terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.38.1"
    }
  }
}

provider "proxmox" {
  # Configuration options
  endpoint  = local.proxmox_data.proxmox.address
  api_token = var.api_token
  insecure  = true
}