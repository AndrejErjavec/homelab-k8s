# IP Plan

These are concrete starting values for the first Kubernetes lab build. Verify them against the real router, DHCP scope, and existing Proxmox services before applying Terraform.

## LAN

| Item                             | Value                           |
| -------------------------------- | ------------------------------- |
| LAN CIDR                         | `192.168.10.0/24`               |
| Gateway                          | `192.168.10.1`                  |
| DNS server                       | `192.168.10.12`                 |
| Proxmox host                     | `192.168.10.10`                 |
| Proxmox bridge                   | `vmbr0`                         |
| Kubernetes node CIDR reservation | `192.168.10.70-192.168.10.79`   |
| MetalLB pool reservation         | `192.168.10.200-192.168.10.220` |
| Local domain                     | `home.arpa`                     |

## Kubernetes VMs

| Name            | Role          | IP              | FQDN                      |
| --------------- | ------------- | --------------- | ------------------------- |
| `k8s-cp-01`     | control plane | `192.168.10.70` | `k8s-cp-01.home.arpa`     |
| `k8s-worker-01` | worker        | `192.168.10.71` | `k8s-worker-01.home.arpa` |
| `k8s-worker-02` | worker        | `192.168.10.72` | `k8s-worker-02.home.arpa` |

## Kubernetes Networks

| Network         | Value                         | Notes                                                                       |
| --------------- | ----------------------------- | --------------------------------------------------------------------------- |
| Pod CIDR        | `10.244.0.0/16`               | Initial kubeadm/Cilium value. Adjust if it overlaps with existing networks. |
| Service CIDR    | `10.96.0.0/12`                | kubeadm default.                                                            |
| MetalLB L2 pool | `192.168.10.200-192.168.10.220` | Keep outside DHCP scope.                                                    |
| Future API VIP  | `192.168.10.69`                | Reserve for HA control plane later.                                         |

## Local DNS Names

Create these in your router DNS, Pi-hole, AdGuard Home, or local DNS server after the services exist.

| Name                     | Target             | Purpose                                   |
| ------------------------ | ------------------ | ----------------------------------------- |
| `k8s-api.home.arpa`      | `192.168.10.70`    | Initial single control-plane API endpoint |
| `argocd.home.arpa`       | MetalLB/ingress IP | Argo CD                                   |
| `grafana.home.arpa`      | MetalLB/ingress IP | Grafana                                   |
| `prometheus.home.arpa`   | MetalLB/ingress IP | Prometheus                                |
| `alertmanager.home.arpa` | MetalLB/ingress IP | Alertmanager                              |
| `gitea.home.arpa`        | MetalLB/ingress IP | Gitea later                               |
| `paperless.home.arpa`    | MetalLB/ingress IP | Paperless later                           |

## DHCP Exclusions

Ensure the router DHCP range does not hand out:

- `192.168.10.10`
- `192.168.10.69-192.168.10.79`
- `192.168.10.200-192.168.10.220`

## Change Checklist

If your LAN is not `192.168.10.0/24`, update these files together:

- `docs/ip-plan.md`
- `infra/terraform/proxmox/terraform.tfvars`
- future Ansible inventory generated from Terraform outputs
