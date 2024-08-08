https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/


- create files
- TWEAK SOME STUFF
- try stuff

```log
TASK [Add Kubernetes APT repository] *******************************************
fatal: [k8s-master]: FAILED! => {"changed": false, "msg": "Failed to update apt cache: W:GPG error: https://prod-cdn.packages.k8s.io/repositories/isv:/kubernete
s:/core:/stable:/v1.28/deb  InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 234654DA9A296436, E:The
repository 'https://pkgs.k8s.io/core:/stable:/v1.28/deb  InRelease' is not signed."}
```

> MOVING ON

