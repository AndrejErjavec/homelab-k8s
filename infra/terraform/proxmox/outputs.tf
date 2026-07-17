output "vm_ips" {
  description = "Static IPv4 addresses assigned to Kubernetes VMs."
  value = {
    for name, vm in local.kubernetes_vms :
    name => split("/", vm.ipv4)[0]
  }
}

output "ansible_inventory_yaml" {
  description = "Starter Ansible inventory generated from Terraform inputs."
  value = yamlencode({
    all = {
      children = {
        kube_control_plane = {
          hosts = {
            for name, vm in local.kubernetes_vms :
            name => {
              ansible_host = split("/", vm.ipv4)[0]
              ansible_user = var.vm_user
            } if vm.role == "control-plane"
          }
        }
        kube_workers = {
          hosts = {
            for name, vm in local.kubernetes_vms :
            name => {
              ansible_host = split("/", vm.ipv4)[0]
              ansible_user = var.vm_user
            } if vm.role == "worker"
          }
        }
        kube_cluster = {
          children = {
            kube_control_plane = {}
            kube_workers       = {}
          }
        }
      }
    }
  })
}

