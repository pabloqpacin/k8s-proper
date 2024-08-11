
- En la terminal de nuestro anfitrión:

```bash
vagrant up
vagrant provision
vagrant ssh host01
```

- En la VM:

```bash
sudo -i
# apt install -y docker.io

docker run --name rancher --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher

docker logs -f rancher 2>&1 | grep "Bootstrap Password:"
```

- En el anfitrión, abrimos un navegador web y visitamos nuestra VM (https://10.0.0.69). Nos dirá que es inseguro, le damos a continuar igualmente.
  - Introducimos la contraseña que nos devuelve el comando `docker logs` anterior.
  - Guardamos en KeePassXC la nueva contraseña autogenerada que se nos presenta (`g0pxRqUV4pV5BnIB`) para el usuario `admin`.
  - Definimos que la URL del Server sea: `https://10.0.0.69`.
  - Deshabilitamos la telemetría y confirmamos el EULA y los T&C.


---

> https://www.youtube.com/watch?v=ZbSFG4cSYhk

Home > Create > Custom


```yaml
Cluster:
  Name: mock-jotelulu
  Appearance: MKU
  Description: -
# Basics:
#   Basics:
#     Kubernetes Version: v1.30.2+rke2r1
#     Cloud Provider: Default - RKE2 Embedded
#     Container Network: calico
#   Security:
#     CIS Profile: (None)
#     Pod Security Admission Configuration Template: Default - RKE2 Embedded
#   System Services:
#     CoreDNS: true
#     NGINX Ingress: true
#     Metrics Server: true
# Member Roles:
#   User: Default Admin (admin) Local
#   Role: Cluster Owner
# Add-On Config:
#   Calico Configuration: ...
# Agent Environment Vars: -
# Cluster Agent: -
# etcd:
#   Automatic Snapshots:
#     Enable: true
#     Cron Schedule: '0 */5 * * *'
#     Keep the last: 5 snapshots per node
#     Backup Snapshots to S3: false
#   Metrics:
#     Only available inside the cluster: true
#     Exposed to the public interface: false
# Fleet Agent: -
Labels & Annotations:
  Lables:
    Key: owner
    Value: pabloqpacin
# Networking:
#   Addressing:
#     Cluster CIDR: -
#     Service CIDR: -
#     Cluster DNS: -
#     Cluster Domain: -
#     NodePort Service Port Range: -
#   TLS Alternate Names: -
#   Authorized Endpoint: false
# Registries:
#   Enable cluster scoped container registry for Rancher system container images: false
# Upgrade Strategy:
#   Control Plane:
#     Control Plane Concurrency: 1
#     Drain Nodes: No
#   Worker Nodes:
#     Control Plane Concurrency: 1
#     Drain Nodes: No
# Advanced:
#   Data directory configuration:
#     Use the same path for System-agent, Provisioning and K8s Distro data directories configuration: true
#     Dat adirectory configuration path: -
#   Addtional Kubelet Args: -
  # Addtional Kubelet Args:
  #   KUBELET_EXTRA_ARGS=--node-ip=$(ip --json a s | jq -r '.[] | if .ifname == "eth1" then .addr_info[] | if .family == "inet" then .local else empty end else empty end')
#   Addtional Controller Manager Args: -
#   Addtional API Server Args: -
#   Addtional Scheduler Args: -
```

<details>
<summary>Movidas YAML</summary>

```yaml
# Calico Configuration
apiServer:
  enabled: false
calicoctl:
  image: rancher/mirrored-calico-ctl
  tag: v3.27.3
certs:
  node:
    cert: null
    commonName: null
    key: null
  typha:
    caBundle: null
    cert: null
    commonName: null
    key: null
felixConfiguration:
  defaultEndpointToHostAction: Drop
  featureDetectOverride: ChecksumOffloadBroken=true
  healthPort: 9099
  logSeveritySys: Info
  wireguardEnabled: false
  xdpEnabled: true
global:
  clusterCIDRv4: ''
  clusterCIDRv6: ''
  systemDefaultRegistry: ''
imagePullSecrets: {}
installation:
  calicoNetwork:
    bgp: Disabled
  controlPlaneTolerations:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
      operator: Exists
    - effect: NoExecute
      key: node-role.kubernetes.io/etcd
      operator: Exists
  enabled: true
  flexVolumePath: /var/lib/kubelet/volumeplugins/
  imagePath: rancher
  imagePrefix: mirrored-calico-
  imagePullSecrets: []
  kubeletVolumePluginPath: None
  kubernetesProvider: ''
ipamConfig:
  autoAllocateBlocks: true
  strictAffinity: true
kubeletVolumePluginPath: None
nodeSelector:
  kubernetes.io/os: linux
podAnnotations: {}
podLabels: {}
resources: {}
tigeraOperator:
  image: rancher/mirrored-calico-operator
  registry: docker.io
  version: v1.32.7
tolerations:
  - effect: NoExecute
    operator: Exists
  - effect: NoSchedule
    operator: Exists
```

```yaml
# Configuration as YAML
apiVersion: provisioning.cattle.io/v1
kind: Cluster
metadata:
  name: mock-jotelulu
  annotations:
    {}
    #  key: string
  labels:
    owner: pabloqpacin
    #  key: string
  namespace: fleet-default
spec:
  clusterAgentDeploymentCustomization:
    appendTolerations:
#      - effect: string
#        key: string
#        operator: string
#        tolerationSeconds: int
#        value: string
    overrideAffinity:
#      nodeAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - preference:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchFields:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          nodeSelectorTerms:
#            - matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchFields:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#      podAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - podAffinityTerm:
#              labelSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              matchLabelKeys:
#                - string
#              mismatchLabelKeys:
#                - string
#              namespaceSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              namespaces:
#                - string
#              topologyKey: string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          - labelSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            matchLabelKeys:
#              - string
#            mismatchLabelKeys:
#              - string
#            namespaceSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            namespaces:
#              - string
#            topologyKey: string
#      podAntiAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - podAffinityTerm:
#              labelSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              matchLabelKeys:
#                - string
#              mismatchLabelKeys:
#                - string
#              namespaceSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              namespaces:
#                - string
#              topologyKey: string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          - labelSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            matchLabelKeys:
#              - string
#            mismatchLabelKeys:
#              - string
#            namespaceSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            namespaces:
#              - string
#            topologyKey: string
    overrideResourceRequirements:
#      claims:
#        - name: string
#      limits:  key: string
#      requests:  key: string
  defaultPodSecurityAdmissionConfigurationTemplateName: ''
  fleetAgentDeploymentCustomization:
    appendTolerations:
#      - effect: string
#        key: string
#        operator: string
#        tolerationSeconds: int
#        value: string
    overrideAffinity:
#      nodeAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - preference:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchFields:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          nodeSelectorTerms:
#            - matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchFields:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#      podAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - podAffinityTerm:
#              labelSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              matchLabelKeys:
#                - string
#              mismatchLabelKeys:
#                - string
#              namespaceSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              namespaces:
#                - string
#              topologyKey: string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          - labelSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            matchLabelKeys:
#              - string
#            mismatchLabelKeys:
#              - string
#            namespaceSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            namespaces:
#              - string
#            topologyKey: string
#      podAntiAffinity:
#        preferredDuringSchedulingIgnoredDuringExecution:
#          - podAffinityTerm:
#              labelSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              matchLabelKeys:
#                - string
#              mismatchLabelKeys:
#                - string
#              namespaceSelector:
#                matchExpressions:
#                  - key: string
#                    operator: string
#                    values:
#                      - string
#                matchLabels:  key: string
#              namespaces:
#                - string
#              topologyKey: string
#            weight: int
#        requiredDuringSchedulingIgnoredDuringExecution:
#          - labelSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            matchLabelKeys:
#              - string
#            mismatchLabelKeys:
#              - string
#            namespaceSelector:
#              matchExpressions:
#                - key: string
#                  operator: string
#                  values:
#                    - string
#              matchLabels:  key: string
#            namespaces:
#              - string
#            topologyKey: string
    overrideResourceRequirements:
#      claims:
#        - name: string
#      limits:  key: string
#      requests:  key: string
  kubernetesVersion: v1.30.2+rke2r1
  localClusterAuthEndpoint:
    caCerts: ''
    enabled: false
    fqdn: ''
  rkeConfig:
    chartValues:
      rke2-calico: {}
        
    dataDirectories:
      k8sDistro: ''
      provisioning: ''
      systemAgent: ''
    etcd:
      disableSnapshots: false
      snapshotRetention: 5
      snapshotScheduleCron: 0 */5 * * *
#      s3:
#        bucket: string
#        cloudCredentialName: string
#        endpoint: string
#        endpointCA: string
#        folder: string
#        region: string
#        skipSSLVerify: boolean
    machineGlobalConfig:
      cni: calico
      disable-kube-proxy: false
      etcd-expose-metrics: false
        
    machinePools:
#      - cloudCredentialSecretName: string
#        controlPlaneRole: boolean
#        displayName: string
#        drainBeforeDelete: boolean
#        drainBeforeDeleteTimeout: string
#        dynamicSchemaSpec: string
#        etcdRole: boolean
#        hostnameLengthLimit: int
#        labels:  key: string
#        machineConfigRef:
#          apiVersion: string
#          fieldPath: string
#          kind: string
#          name: string
#          namespace: string
#          resourceVersion: string
#          uid: string
#        machineDeploymentAnnotations:  key: string
#        machineDeploymentLabels:  key: string
#        machineOS: string
#        maxUnhealthy: string
#        name: string
#        nodeStartupTimeout: string
#        paused: boolean
#        quantity: int
#        rollingUpdate:
#          maxSurge: 
#          maxUnavailable:
#        taints:
#          - effect: string
#            key: string
#            timeAdded: string
#            value: string
#        unhealthyNodeTimeout: string
#        unhealthyRange: string
#        workerRole: boolean
    machineSelectorConfig:
      - config:
          protect-kernel-defaults: false
#      - config:  
#        machineLabelSelector:
#          matchExpressions:
#            - key: string
#              operator: string
#              values:
#                - string
#          matchLabels:  key: string
    registries:
      configs:
        {}
        #  authConfigSecretName: string
#        caBundle: string
#        insecureSkipVerify: boolean
#        tlsSecretName: string
      mirrors:
        {}
        #  endpoint:
#          - string
#        rewrite:  key: string
    upgradeStrategy:
      controlPlaneConcurrency: '1'
      controlPlaneDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
#        ignoreErrors: boolean
#        postDrainHooks:
#          - annotation: string
#        preDrainHooks:
#          - annotation: string
      workerConcurrency: '1'
      workerDrainOptions:
        deleteEmptyDirData: true
        disableEviction: false
        enabled: false
        force: false
        gracePeriod: -1
        ignoreDaemonSets: true
        skipWaitForDeleteTimeoutSeconds: 0
        timeout: 120
#        ignoreErrors: boolean
#        postDrainHooks:
#          - annotation: string
#        preDrainHooks:
#          - annotation: string
#    additionalManifest: string
#    etcdSnapshotCreate:
#      generation: int
#    etcdSnapshotRestore:
#      generation: int
#      name: string
#      restoreRKEConfig: string
#    infrastructureRef:
#      apiVersion: string
#      fieldPath: string
#      kind: string
#      name: string
#      namespace: string
#      resourceVersion: string
#      uid: string
#    machinePoolDefaults:
#      hostnameLengthLimit: int
#    machineSelectorFiles:
#      - fileSources:
#          - configMap:
#              defaultPermissions: string
#              items:
#                - dynamic: boolean
#                  hash: string
#                  key: string
#                  path: string
#                  permissions: string
#              name: string
#            secret:
#              defaultPermissions: string
#              items:
#                - dynamic: boolean
#                  hash: string
#                  key: string
#                  path: string
#                  permissions: string
#              name: string
#        machineLabelSelector:
#          matchExpressions:
#            - key: string
#              operator: string
#              values:
#                - string
#          matchLabels:  key: string
#    networking:
#      stackPreference: string
#    provisionGeneration: int
#    rotateCertificates:
#      generation: int
#      services:
#        - string
#    rotateEncryptionKeys:
#      generation: int
  machineSelectorConfig:
    - config: {}
#  agentEnvVars:
#    - name: string
#      value: string
#  cloudCredentialSecretName: string
#  clusterAPIConfig:
#    clusterName: string
#  defaultClusterRoleForProjectMembers: string
#  enableNetworkPolicy: boolean
#  redeploySystemAgentGeneration: int
__clone: true
```

</details>

---

```bash
# host01
curl --insecure -fL https://10.0.0.69/system-agent-install.sh | sudo  sh -s - --server https://10.0.0.69 --label 'cattle.io/os=linux' --token knbz8ts4th4hblrfrc8lgx7dcs7dlwqdcdqrhspsg6gnl22fps7jxn --ca-checksum 29c32ded54782dc6309466db5f70990bb5c8f3e0f9ae91a1c8be693bbb6beaca --etcd --controlplane --worker

# ...
# fail again ffs
```

---

<!-- Clusters > mock-jotelulu

```yaml
Registration:
  Step 1:
    Node Role:
      etcd: true
      Control Plane: true
      Worker: true
  Step 2:
    Insecure: true
    Registration Command: curl --insecure -fL https://192.168.61.69/system-agent-install.sh | sudo sh -s - --server https://192.168.61.69 --label 'cattle.io/os=linux' --token 96wxzmc9bs8lwgfnpvmd5r8tmmrpt2r8tptv489v2c75cdsvt9xpq9 --ca-checksum 6955e08bdfe14542e8bb205807c9fdcad836c98ed13645e316c837829ad45fe3 --etcd --controlplane --worker 
```

---

Introducimos el siguiente comando en `host02`, `host03` y `host04`.

```bash
for i in {2..4}; do
  vagrant ssh host0$i
  sudo -i

  # Introducimos el comando
  curl --insecure -fL https://192.168.61.69/system-agent-install.sh | sudo sh -s - --server https://192.168.61.69 --label 'cattle.io/os=linux' --token 96wxzmc9bs8lwgfnpvmd5r8tmmrpt2r8tptv489v2c75cdsvt9xpq9 --ca-checksum 6955e08bdfe14542e8bb205807c9fdcad836c98ed13645e316c837829ad45fe3 --etcd --controlplane --worker 

  # Esperamos unos 10 minutos antes de hacer el siguiente; vamos controlando en la web gui de Rancher
  sleep 600
done
``` -->

Para el `host02`, queremos los componentes `etcd`, `Control Plane` y `Worker`. Para `host03` y `host04`, solo `Worker`. En todos los casos hay que seleccionar **Insecure**.


```bash
vagrant ssh host02
sudo -i

curl --insecure -fL https://192.168.61.69/system-agent-install.sh | sudo  sh -s - --server https://192.168.61.69 --label 'cattle.io/os=linux' --token 7vtv9pq2cx5gpchtdl8kmhbbk2t664pxqd96lfw7f6n49zxzhv5rgh --ca-checksum 3aa1cd32aebf937735e0c164159e9f361eab196e1efbcc7788874f5540154d23 --etcd --controlplane --worker

sleep 600
```

La conexión del nodo puede tardar como 10 minutos. Hay que estar en Rancher > Cluster Management > Machines, y esperar a que pase de *Reconciling* a *Running*.

Al principio habrá un mensaje tipo "Waiting for probes: calico, etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kubelet". Poco a poco irá bajando el número de componentes, hasta que se complete el proceso.

Ahora lo hacemos para `host03` pero solo el rol `Worker`. Lo mismo para `host04`.

```bash
vagrant ssh host03
sudo -i

curl --insecure -fL https://192.168.61.69/system-agent-install.sh | sudo  sh -s - --server https://192.168.61.69 --label 'cattle.io/os=linux' --token 7vtv9pq2cx5gpchtdl8kmhbbk2t664pxqd96lfw7f6n49zxzhv5rgh --ca-checksum 3aa1cd32aebf937735e0c164159e9f361eab196e1efbcc7788874f5540154d23 --worker
sleep 600
```

> EL NODO NUNCA SE UNE! ABANDONAMOS RANCHER POR AHORA!

```bash
# vagrant ssh host04
# sudo -i

# curl --insecure -fL https://192.168.61.69/system-agent-install.sh | sudo  sh -s - --server https://192.168.61.69 --label 'cattle.io/os=linux' --token 7vtv9pq2cx5gpchtdl8kmhbbk2t664pxqd96lfw7f6n49zxzhv5rgh --ca-checksum 3aa1cd32aebf937735e0c164159e9f361eab196e1efbcc7788874f5540154d23 --worker
# sleep 600
```


