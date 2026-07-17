# Ansible

Ansible will own base operating system configuration and Kubernetes node preparation.

Planned scope:

- users and packages
- timezone and NTP
- disable swap
- kernel modules: `overlay`, `br_netfilter`
- sysctl settings for Kubernetes networking
- containerd installation and configuration
- kubeadm, kubelet, and kubectl installation

