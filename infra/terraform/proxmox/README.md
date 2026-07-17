# Proxmox Terraform

This directory provisions the initial kubeadm Kubernetes VMs from an existing Proxmox cloud-init template.

## Files

- `versions.tf`: Terraform and provider requirements.
- `providers.tf`: Proxmox provider configuration.
- `variables.tf`: Inputs.
- `locals.tf`: VM definitions.
- `main.tf`: VM resources.
- `outputs.tf`: IP and Ansible inventory outputs.
- `terraform.tfvars.example`: Copy to `terraform.tfvars` and edit for your environment.
- `cloud-init-template.md`: Manual Proxmox template creation instructions.

## Usage

```sh
cd infra/terraform/proxmox
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Keep `terraform.tfvars` out of Git because it may contain API tokens and local details.

