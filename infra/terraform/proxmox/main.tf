resource "proxmox_virtual_environment_vm" "ubuntu_template" {
  name      = "ubuntu-template"
  node_name = var.proxmox_node_name
  vm_id     = var.template_vm_id

  template        = true
  on_boot         = true
  stop_on_destroy = true

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
  }

  network_device {
    bridge = "vmbr0"
  }

}

resource "proxmox_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node_name

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "noble-server-cloudimg-amd64.qcow2"
}


resource "proxmox_virtual_environment_vm" "kubernetes" {
  for_each = local.kubernetes_vms

  name        = each.key
  description = each.value.description
  node_name   = var.proxmox_node_name
  vm_id       = each.value.vm_id
  tags        = concat(var.vm_tags, [each.value.role])

  started = true

  lifecycle {
    precondition {
      condition = length(distinct([
        for vm in values(local.kubernetes_vms) : vm.vm_id
      ])) == length(local.kubernetes_vms)
      error_message = "Every Kubernetes VM must have a unique Proxmox VM ID."
    }

    precondition {
      condition = length(distinct([
        for vm in values(local.kubernetes_vms) : split("/", vm.ipv4)[0]
      ])) == length(local.kubernetes_vms)
      error_message = "Every Kubernetes VM must have a unique IPv4 address."
    }

    precondition {
      condition = (
        can(cidrhost(each.value.ipv4, 0)) &&
        can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}/([0-9]|[12][0-9]|3[0-2])$", each.value.ipv4))
      )
      error_message = "${each.key} must have a valid CIDR-formatted IPv4 address."
    }
  }

  clone {
    vm_id = proxmox_virtual_environment_vm.ubuntu_template.vm_id
    full  = true
  }

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = false
  }

  startup {
    order      = each.value.role == "control-plane" ? "1" : "2"
    up_delay   = each.value.role == "control-plane" ? "30" : "0"
    down_delay = "30"
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory_mb
    floating  = each.value.memory_mb
  }

  disk {
    datastore_id = var.target_datastore_id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = each.value.disk_gb
  }

  initialization {
    datastore_id = var.cloud_init_datastore_id

    dns {
      domain  = var.dns_domain
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = each.value.ipv4
        gateway = var.gateway_ipv4
      }
    }

    user_account {
      username = var.vm_user
      keys     = [local.ssh_public_key]
    }
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # operating_system {
  #   type = "l26"
  # }
}
