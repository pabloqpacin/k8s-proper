# k8s-proper

| setup                 | ok    | info
| ---                   | ---   | ---
| 01_jotelulu           | YES   | 3 vms + docker
| 02_rancher_cluster    | NO    | 4 vms + docker; Rancher no engancha el segundo nodo
| 03_k8s_ansible        | NO    | deprecated configuration
| 04_jotelulu_cluster   | -     | 01_jotelulu + k8s script
| 05_private_registry   | -     | 04_jotelulu_cluster + private registry bs


- [ ] **02_rancher_cluster**: troubleshoot: try kubelet's `--node-ip`
- [ ] **04_jotelulu_cluster**: cluster via script
- [ ] **05_private_registry**: ...

