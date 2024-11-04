terraform {
  required_version = ">= 1.0"
}

locals {
  proxmox_data = yamldecode(file(var.proxmox_data))
}

resource "proxmox_virtual_environment_pool" "operations_pool" {
  comment = "Managed by Terraform"
  pool_id = local.proxmox_data.proxmox.pool.id
}

resource "proxmox_virtual_environment_vm" "okd4" {
  for_each = { for vm in local.proxmox_data.proxmox.vms : vm.name => vm }

  lifecycle {
    ignore_changes = [
      started
    ]
  }

  vm_id         = each.value.id
  name          = each.value.name
  description   = each.value.description
  node_name     = each.value.node
  on_boot       = false
  started       = each.value.started
  pool_id       = proxmox_virtual_environment_pool.operations_pool.pool_id
  tablet_device = false
  boot_order    = ["scsi0", "ide2", "net0"]
  scsi_hardware = "virtio-scsi-pci"

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  cdrom {
    enabled   = "true"
    file_id   = each.value.cdrom_file
    interface = "ide2"
  }

  cpu {
    sockets = 1
    cores   = 4
    numa    = false
    type    = "x86-64-v2-AES"

  }

  disk {
    file_format  = "raw"
    interface    = "scsi0"
    datastore_id = "local-zfs"
    size         = "120"
  }

  memory {
    dedicated = each.value.memory * 1024
    floating  = each.value.memory * 1024
  }

  network_device {
    model       = "virtio"
    bridge      = "vmbr3"
    mac_address = each.value.mac_address
    queues      = 2
    mtu         = 1450
  }

  vga {
    enabled = true
    type    = "std"
  }

}
