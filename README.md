# k8s-proper

- [k8s-proper](#k8s-proper)
  - [about](#about)
    - [repo](#repo)
    - [todo](#todo)
  - [01\_jotelulu\_cluster](#01_jotelulu_cluster)
  - [02\_cluster\_nfs](#02_cluster_nfs)
    - [Levantar entorno](#levantar-entorno)
    - [Crear cluster Kubernetes](#crear-cluster-kubernetes)
    - [Habilitar dashboards](#habilitar-dashboards)
    - [Demos](#demos)
      - [prueba\_webapp.sh](#prueba_webappsh)
      - [wordpress-mysql\_pv-pvc-cm-svc-deploy.yaml](#wordpress-mysql_pv-pvc-cm-svc-deployyaml)
      - [restauración](#restauración)
  - [03\_private\_registry](#03_private_registry)


## about

### repo

| setup                 | ok    | info
| ---                   | ---   | ---
| 01_jotelulu_cluster   | YES   | 3 vms + k8s script
| 02_cluster_nfs*       | YES   | 4 vms + ansible NFS + k8s script + Helm dashboards
| 03_private_registry   | 
|                       | 

(*) Demo `nfs_wordpress` solo funciona en rama [legacy/nfs_wordpress](https://github.com/pabloqpacin/k8s-proper/tree/legacy/nfs_wordpress) por la configuración de NFS en `setup/` 

### todo

<!-- - [ ] **02_rancher_cluster**: troubleshoot: try kubelet's `--node-ip` -->

- [ ] private registry
- [ ] Rancher (Helm, ...)
- [x] Helm: Helm Dashboard + Kubernetes Dashboard
- [ ] Helm apps: mywebapp, wordpress_nfs
- [x] NFS
  - [x] wordpress bs
- STUDY
  - [ ] ingress ([src](https://www.youtube.com/watch?v=SUk_Nm5BiPw))


---

## 01_jotelulu_cluster

<details>
<summary>Mejor el 02 directamente!</summary>

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


- Nos conectamos al segundo y tercer nodo, ejecutamos el script y cuando termine introducimos el token que se generó previamente. No perdemos de vista los comandos `watch` en el `host01`.

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

</details>


---

<!-- ## 02_cluster_nfs_helm_dashboards -->
## 02_cluster_nfs

### Levantar entorno

- Config virtualbox en anfitrión Linux

```bash
bash scripts/host_vbox_network.sh
```

- Levantar vms con Vagrant

```bash
cd 02_cluster_nfs
vagrant up
```

### Crear cluster Kubernetes

- Nos conectamos a cada nodo para ejecutar el script que instalará los componentes de kubernetes <!--(TODO: Ansible)-->; importante no perder el token de `kubeadm`

```bash
vagrant ssh host01
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # Copiamos el token a otro doc o abrimos otra pane en tmux. NO PERDER EL TOKEN.

    watch kubectl get all --all-namespaces
    watch kubectl get nodes -o wide
}
```

```log
kubeadm join 10.0.0.248:6443 --token 3oliin.jmfnmtkvyn6dydl3 \
        --discovery-token-ca-cert-hash sha256:32e92228a7b899d7a30c005ecff12c34764ac876ebe351d7be63ce69fb86a92c
```

```bash
vagrant ssh host02
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # INTRODUCIMOS EL TOKEN
    exit
}

vagrant ssh host03
{
    sudo -i
    bash /opt/k8s-jotelulu.sh
    # INTRODUCIMOS EL TOKEN
    exit
}
```

- Con el cluster a punto, podemos detener las vms y hacer una *snapshot*

```bash
vagrant halt

vagrant snapshot push
vagrant snapshot list

# vagrant snapshot pop --no-delete --provision

vagrant up
```

### Habilitar dashboards

- Nos conectamos al *controlplane* para instalar la movida y crear un servicio que disponibilice los dashboards en caso de reinicios

```bash
vssh host01
{
    bash /opt/helm_dashboards.sh
    cat ~/bearer_token
}
```

- Consultamos los dashboards desde el anfitrión

```bash
xdg-open http://10.0.0.48:8080
xdg-open http://10.0.0.48:8443      # + bearer_token
```

### Demos

#### prueba_webapp.sh

```bash
vagrant ssh host01
{
  sudo -i
  bash /opt/prueba_webapp.sh

  # kubectl get svc web-svc
  WEBAPP_PORT=$(kubectl get svc web-svc -o jsonpath='{.spec.ports[0].nodePort}')

  # kubectl delete -f ~/k8s/sondas/sonda-http.yaml
}

# xdg-open http://10.0.0.248:30002
xdg-open http://10.0.0.248:${WEBAPP_PORT}
```

#### wordpress-mysql_pv-pvc-cm-svc-deploy.yaml

<!-- 
- [ ] Helm chart
- [ ] tweak port
- [ ] namespace?
- [ ] version updates?
 -->

```bash
vagrant ssh hostnfs
{
  sudo -i
  watch tree /var/datos
}

vagrant ssh host01
{
  sudo -i
  # sed -i 's/wordpress:4.8-apache/wordpress:6.2-apache/' /opt/word*.yaml
  # sed -i 's/mysql:5.6/mysql:8.0/' /opt/word*.yaml

  kubectl apply -f /opt/wordpress-mysql_pv-pvc-cm-svc-deploy.yaml
  watch kubectl get all

  # kubectl get svc wordpress
  WP_PORT=$(kubectl get svc wordpress -o jsonpath='{.spec.ports[0].nodePort}')
}

# xdg-open http://10.0.0.248:31636
xdg-open http://10.0.0.248:${WP_PORT}
  # Wordpress web GUI installation wizard
  # site==foo, name==bar, pass==ORnFH7IMEkDa$6AB4Z, email==foo@bar.com
```


#### restauración

- Con las pruebas terminadas, corremos `vagrant snapshot pop --no-delete` para restaurar las vms o `vagrant destroy` del tirón para pasar al siguiente apartado. Si por lo que sea restauramos, lo ideal es correr `watch kubectl get pods --all-namespaces` antes de operar para evitar problemas.

```bash
vagrant halt && \
vagrant snapshot pop --no-delete

# Verificar cluster operativo antes de nuevas operaciones
vagrant ssh host01
{
  watch kubectl get pods --all-namespaces
}
```


---


## 03_private_registry

---

