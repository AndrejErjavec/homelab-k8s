locals {
  ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  kubernetes_vms = {
    k8s-cp-01 = {
      vm_id       = 401
      description = "Kubernetes control-plane node"
      role        = "control-plane"
      ipv4        = "192.168.10.91/24"
      cores       = 2
      memory_mb   = 2048
      disk_gb     = 20
    }

    k8s-worker-01 = {
      vm_id       = 411
      description = "Kubernetes worker node"
      role        = "worker"
      ipv4        = "192.168.10.92/24"
      cores       = 2
      memory_mb   = 2048
      disk_gb     = 20
    }

    k8s-worker-02 = {
      vm_id       = 412
      description = "Kubernetes worker node"
      role        = "worker"
      ipv4        = "192.168.10.93/24"
      cores       = 2
      memory_mb   = 2048
      disk_gb     = 20
    }
  }
}
