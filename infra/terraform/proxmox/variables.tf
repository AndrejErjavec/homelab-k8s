variable "proxmox_endpoint" {
  description = "Proxmox API endpoint, for example https://192.168.10.10:8006/."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the provider's expected token format."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for the Proxmox API. Acceptable for a lab with self-signed certs."
  type        = bool
  default     = true
}

variable "proxmox_node_name" {
  description = "Proxmox node where the VMs will be created."
  type        = string
  default     = "pve"
}

variable "template_vm_id" {
  description = "VM ID of the Ubuntu 24.04 cloud-init template."
  type        = number
  default     = 9000
}

variable "target_datastore_id" {
  description = "Datastore for cloned VM disks."
  type        = string
  default     = "local-lvm"
}

variable "cloud_init_datastore_id" {
  description = "Datastore for cloud-init disks."
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Proxmox bridge for Kubernetes VM NICs."
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key injected into cloud-init."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_user" {
  description = "Default cloud-init user."
  type        = string
  default     = "ubuntu"
}

variable "dns_servers" {
  description = "DNS servers configured by cloud-init."
  type        = list(string)
  default     = ["192.168.10.12"]
}

variable "dns_domain" {
  description = "Local DNS search domain."
  type        = string
  default     = "home.arpa"
}

variable "gateway_ipv4" {
  description = "Default IPv4 gateway for Kubernetes VMs."
  type        = string
  default     = "192.168.10.1"
}

variable "vm_tags" {
  description = "Tags added to all Kubernetes VMs."
  type        = list(string)
  default     = ["terraform", "kubernetes", "kubeadm"]
}
