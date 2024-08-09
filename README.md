# k8s-proper

- [k8s-proper](#k8s-proper)
  - [repo](#repo)
  - [todo](#todo)
  - [01\_jotelulu\_cluster](#01_jotelulu_cluster)


## repo

| setup                 | ok    | info
| ---                   | ---   | ---
| 01_jotelulu_cluster   | YES   | 3 vms + k8s script
|                       | 


## todo

<!-- - [ ] **02_rancher_cluster**: troubleshoot: try kubelet's `--node-ip` -->

- [ ] dashboard
- [ ] wordpress bs
- [ ] private registry
- [ ] Rancher
- [ ] NFS


---

## 01_jotelulu_cluster

- Lo primero es cambiar la configuración de red de virtualbox en el anfitrión si es Linux

```bash
bash scripts/host_vbox_network.sh
```

- Iniciamos el cluster. ~~Cuando las máquinas estén creadas~~ Tras ejecutar los scripts, hacemos un snapshot para restaurar por si acaso.

```bash
cd 01_jotelulu_cluster

vagrant up

vagrant snapshot list
# vagrant snapshot push

# vagrant snapshot pop
```

- Accedemos al `host01`,  que será el master o controlplane. Ejecutamos el script (tardará unos minutos) y nos aseguramos de no perder de vista el token para el `join`. Controlamos que kubernetes se despliegue sin errores.

```bash
vagrant ssh host01
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # Copiamos el token a otro doc o abrimos otra pane en tmux. NO PERDER EL TOKEN.

    watch kubectl get nodes -o wide
    watch kubectl -n kube-system get pods -o wide
}
```
```log
kubeadm join 10.0.0.248:6443 --token gukd69.h25y9i8r1xja681h \
        --discovery-token-ca-cert-hash sha256:66d0e19bef12dda7eaadef4e1c7b43713b0167f131e1bec8c479b61d23a46d08
```


- Nos conectamos al segundo y tercer nodo, ejecutamos el script y cuando termine introducimos el token que se generó previamente.

```bash
vagrant ssh host02
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # INTRODUCIMOS EL TOKEN
}

vagrant ssh host03
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # INTRODUCIMOS EL TOKEN
}
```

- Detenemos las vms y ~~renovamos~~ creamos snapshots. Cuando queramos restaurarlas, pasamos la flag `--no-delete` para mantener la snapshot (ya que este es un estado ideal, cluster limpico... *y totalmente operativo sin conflictos de red ni nada...*)

```bash
vagrant halt

vagrant snapshot push
vagrant snapshot list

# vagrant halt && \
# vagrant snapshot pop --no-delete
```

<!-- 
```log
root@host01 ~$ kcgn
NAME     STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
host01   Ready    control-plane   50m     v1.29.7   10.0.0.248    <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.6.20
host02   Ready    <none>          4m31s   v1.29.7   10.0.0.247    <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.6.20
host03   Ready    <none>          4m29s   v1.29.7   10.0.0.4      <none>        Debian GNU/Linux 12 (bookworm)   6.1.0-17-amd64   containerd://1.6.20

root@host01 ~$ kcga -n kube-system
NAME                                 READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
pod/coredns-76f75df574-pc7tj         1/1     Running   0          50m     10.0.239.196   host01   <none>           <none>
pod/coredns-76f75df574-zmgkg         1/1     Running   0          50m     10.0.239.193   host01   <none>           <none>
pod/etcd-host01                      1/1     Running   0          50m     10.0.0.248     host01   <none>           <none>
pod/kube-apiserver-host01            1/1     Running   0          50m     10.0.0.248     host01   <none>           <none>
pod/kube-controller-manager-host01   1/1     Running   0          50m     10.0.0.248     host01   <none>           <none>
pod/kube-proxy-4n6k6                 1/1     Running   0          4m34s   10.0.0.4       host03   <none>           <none>
pod/kube-proxy-mj4tp                 1/1     Running   0          50m     10.0.0.248     host01   <none>           <none>
pod/kube-proxy-x6x5m                 1/1     Running   0          4m36s   10.0.0.247     host02   <none>           <none>
pod/kube-scheduler-host01            1/1     Running   0          50m     10.0.0.248     host01   <none>           <none>

NAME               TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
service/kube-dns   ClusterIP   10.0.0.10    <none>        53/UDP,53/TCP,9153/TCP   50m   k8s-app=kube-dns

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE   CONTAINERS   IMAGES                               SELECTOR
daemonset.apps/kube-proxy   3         3         3       3            3           kubernetes.io/os=linux   50m   kube-proxy   registry.k8s.io/kube-proxy:v1.29.7   k8s-app=kube-proxy

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                    SELECTOR
deployment.apps/coredns   2/2     2            2           50m   coredns      registry.k8s.io/coredns/coredns:v1.11.1   k8s-app=kube-dns

NAME                                 DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                                    SELECTOR
replicaset.apps/coredns-76f75df574   2         2         2       50m   coredns      registry.k8s.io/coredns/coredns:v1.11.1   k8s-app=kube-dns,pod-template-hash=76f75df574
```
-->



