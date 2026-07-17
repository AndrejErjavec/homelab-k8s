# Architecture

## Responsibility Boundaries

| Layer | Tool | Owns |
| --- | --- | --- |
| VM infrastructure | Terraform | Proxmox VM lifecycle, VM sizing, static IP metadata |
| Node configuration | Ansible | OS packages, kernel settings, containerd, kubeadm/kubelet/kubectl |
| Kubernetes bootstrap | kubeadm | Initial control plane and worker joins |
| Cluster desired state | Argo CD | Add-ons, apps, policies, observability, ingress, storage |

Terraform should not manage normal Kubernetes add-ons or applications. Once Argo CD is installed, in-cluster desired state should live under GitOps.

## Initial Cluster

| Node | Role | vCPU | RAM | Disk |
| --- | --- | ---: | ---: | ---: |
| k8s-cp-01 | control plane | 2 | 4096 MB | 50 GB |
| k8s-worker-01 | worker | 2 | 6144 MB | 60 GB |
| k8s-worker-02 | worker | 2 | 6144 MB | 60 GB |

## Later Iterations

- Rebuild as three control-plane nodes plus workers.
- Add kube-vip or HAProxy/keepalived for the API server endpoint.
- Practice etcd backup and restore.
- Add physical mini PCs after switching and VLAN foundations improve.

