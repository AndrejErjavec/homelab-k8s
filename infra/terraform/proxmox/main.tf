# TODO:
# You can also configure additional Proxmox users and roles using virtual_environment_user and virtual_environment_role resources of the provider.

resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-template"
  node_name = var.proxmox_node_name
  vm_id     = var.template_vm_id

  template = true
  started  = false

  machine     = "q35"
  bios        = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = var.cloud_init_datastore_id
    type         = "4m"
  }

  disk {
    datastore_id = var.target_datastore_id
    import_from  = proxmox_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    # user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  url       = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  file_name = "jammy-server-cloudimg-amd64.qcow2"
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  name        = "ubuntu-vm"
  description = "Ubuntu VM cloned from the Terraform-managed template"
  node_name   = var.proxmox_node_name
  started     = false
  tags        = ["terraform", "ubuntu"]

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.vm_id
    full  = true
  }

  initialization {
    datastore_id = var.cloud_init_datastore_id

    user_account {
      username = var.vm_user
      keys     = [local.ssh_public_key]
    }
  }

  # overrides
  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }
}


# resource "proxmox_virtual_environment_vm" "kubernetes" {
#   for_each = local.kubernetes_vms

#   name        = each.key
#   description = each.value.description
#   node_name   = var.proxmox_node_name
#   vm_id       = each.value.vm_id
#   tags        = concat(var.vm_tags, [each.value.role])

#   clone {
#     vm_id = var.template_vm_id
#     full  = true
#   }

#   agent {
#     enabled = true
#   }

#   stop_on_destroy = true

#   cpu {
#     cores = each.value.cores
#     type  = "host"
#   }

#   memory {
#     dedicated = each.value.memory_mb
#     floating  = each.value.memory_mb
#   }

#   disk {
#     datastore_id = var.target_datastore_id
#     interface    = "scsi0"
#     iothread     = true
#     discard      = "on"
#     size         = each.value.disk_gb
#   }

#   initialization {
#     datastore_id = var.cloud_init_datastore_id

#     dns {
#       domain  = var.dns_domain
#       servers = var.dns_servers
#     }

#     ip_config {
#       ipv4 {
#         address = each.value.ipv4
#         gateway = var.gateway_ipv4
#       }
#     }

#     user_account {
#       username = var.vm_user
#       keys     = [local.ssh_public_key]
#     }
#   }

#   network_device {
#     bridge = var.network_bridge
#     model  = "virtio"
#   }

#   operating_system {
#     type = "l26"
#   }
# }
