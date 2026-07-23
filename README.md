# Proxmox Kubernetes Homelab

Production-style Kubernetes homelab for learning DevOps, Kubernetes operations, IaC, GitOps, observability, security, CI/CD, backups, and failure recovery.

## Current Direction

- Proxmox provisions Ubuntu Server VMs.
- Terraform owns VM lifecycle and selected external infrastructure later.
- Ansible owns base OS and Kubernetes node preparation.
- kubeadm bootstraps upstream Kubernetes.
- Argo CD owns normal in-cluster add-ons and applications.

## Prerequisites

Before provisioning the Kubernetes VMs, make sure you have:

- A working Proxmox VE host that is reachable from your workstation.
- A Proxmox API token with permission to create and manage the VMs, disks,
  cloud-init configuration, and downloaded cloud image used by this project.
- The Proxmox datastores and network bridge configured with the names used in
  `infra/terraform/proxmox/terraform.tfvars`.
- The Kubernetes node addresses reserved outside the DHCP pool as documented in
  `docs/ip-plan.md`.
- Terraform 1.8 or newer.
- OpenSSH tools, including `ssh`, `ssh-keygen`, and optionally `ssh-agent`.
- An SSH public/private key pair for access to the provisioned Ubuntu VMs.

Do not commit Proxmox API tokens, Terraform state, `terraform.tfvars`, or SSH
private keys.

## Create the SSH key pair

Terraform does not generate an SSH key. It reads an existing public key and
passes it to cloud-init, which adds it to the configured Ubuntu user's
`authorized_keys` file.

First, check whether the dedicated homelab key already exists:

```sh
ls -l ~/.ssh/homelab_k8s_ed25519 ~/.ssh/homelab_k8s_ed25519.pub
```

If it does not exist, generate it:

```sh
ssh-keygen \
  -t ed25519 \
  -a 100 \
  -f ~/.ssh/homelab_k8s_ed25519 \
  -C "homelab-k8s"
```

Use a passphrase when prompted. The command creates:

- `~/.ssh/homelab_k8s_ed25519`: the private key; keep it secret.
- `~/.ssh/homelab_k8s_ed25519.pub`: the public key Terraform may read.

The `-a 100` option increases the work required to guess the private-key
passphrase. The `-C "homelab-k8s"` option adds an identifying comment to the
public key.

Optionally load the private key into the macOS SSH agent and Keychain:

```sh
ssh-add --apple-use-keychain ~/.ssh/homelab_k8s_ed25519
```

Set the public-key path and VM username in the uncommitted
`infra/terraform/proxmox/terraform.tfvars` file:

```hcl
ssh_public_key_path = "~/.ssh/homelab_k8s_ed25519.pub"
vm_user             = "ubuntu"
```

Confirm the public key before provisioning:

```sh
ssh-keygen -lf ~/.ssh/homelab_k8s_ed25519.pub
```

After `terraform apply` and cloud-init have completed, test access to the
control-plane VM:

```sh
ssh -i ~/.ssh/homelab_k8s_ed25519 ubuntu@192.168.10.91
```

Because the key uses a custom filename, SSH will not select it automatically
unless it is loaded into `ssh-agent`, passed with `-i`, or configured in
`~/.ssh/config`. For convenient access, add:

```sshconfig
Host k8s-cp-01
    HostName 192.168.10.91
    User ubuntu
    IdentityFile ~/.ssh/homelab_k8s_ed25519
    IdentitiesOnly yes
```

You can then connect with:

```sh
ssh k8s-cp-01
```

The private key remains on your workstation. The VM stores only the matching
public key injected by Terraform through cloud-init.

## Documentation

The living documentation starts in `docs/README.md`.

Use it as the source of truth for understanding, building, operating, and troubleshooting the homelab. Setup instructions live under `docs/setup/`, operational procedures under `docs/operations/`, and stable technical reference under `docs/reference/`.

## First Milestone

1. Finalize the IP plan in `docs/ip-plan.md`.
2. Build the Ubuntu cloud-init template in Proxmox.
3. Provision the first three Kubernetes VMs with Terraform.
4. Prepare nodes with Ansible.
5. Bootstrap Kubernetes with kubeadm.
