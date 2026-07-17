# Kubernetes Bootstrap

Manual bootstrap notes for kubeadm go here.

Expected sequence:

1. Run Ansible node preparation.
2. Initialize `k8s-cp-01` with kubeadm.
3. Join workers.
4. Install Cilium.
5. Verify nodes, CoreDNS, and pod networking.
6. Install Argo CD once manually.

