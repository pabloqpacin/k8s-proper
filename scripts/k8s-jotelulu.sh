#!/usr/bin/env bash

#
# Somos usuario Root en servidores Debian 12 LTS
#

prepare_systems(){
    apt-get update && apt-get upgrade -y && apt autoremove -y

    # free -h; cat /proc/swaps
    sed -i '/swap/s/^/# /' /etc/fstab &&
    swapoff --all

    # sudo hostnamectl set-hostname foo

    {
tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
    }

    cat<<EOF | tee -a /etc/hosts

10.0.0.248: SRV-SETE05-001
10.0.0.247: SRV-SETE05-002
10.0.0.4: SRV-SETE05-003
EOF

}


# 2_k8s_master(){
# apt-get install -y apt-transport-https ca-certificates curl gpg
# # mkdir /etc/apt/keyrings
# curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
#     gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | \
#     tee /etc/apt/sources.list.d/kubernetes.list

#     apt-get update
# # Obj:1 http://deb.debian.org/debian bookworm InRelease
# # Obj:2 http://deb.debian.org/debian bookworm-updates InRelease
# # Obj:3 http://security.debian.org/debian-security bookworm-security InRelease
# # Ign:4 https://packages.cloud.google.com/apt kubernetes-xenial InRelease
# # Err:5 https://packages.cloud.google.com/apt kubernetes-xenial Release
# #   404  Not Found [IP: 142.250.185.206 443]
# # Leyendo lista de paquetes... Hecho
# # E: El repositorio «https://apt.kubernetes.io kubernetes-xenial Release» no tiene un fichero de Publicación.
# # N: No se puede actualizar de un repositorio como este de forma segura y por tanto está deshabilitado por omisión.
# # N: Vea la página de manual apt-secure(8) para los detalles sobre la creación de repositorios y la configuración de usuarios.

# }

# change 1.29 for 1.30
setup_k8s_docker_containerd(){
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    # Download the public signing key for the Kubernetes package repositories. The same signing key is used for all repositories so you can disregard the version in the URL:
    if [ ! -d '/etc/apt/keyrings' ]; then sudo mkdir -p -m 755 /etc/apt/keyrings; fi
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    # Add the appropriate Kubernetes apt repository. Please note that this repository have packages only for Kubernetes 1.29
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    # Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
    sudo apt-get update
    sudo apt-get install -y kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    sudo systemctl enable --now kubelet

    apt install -y docker.io

    if [ ! -d '/etc/containerd' ]; then mkdir /etc/containerd; fi
    sh -c "containerd config default > /etc/containerd/config.toml"
    sudo sed -i 's/ SystemdCgroup = false/ SystemdCgroup = true/' /etc/containerd/config.toml
    systemctl restart containerd.service
    systemctl restart kubelet.service
}

setup_master(){
    kubeadm config images pull
    kubeadm init --pod-network-cidr=10.0.0.0/16

    token_saved=''
    while [[ $token_saved != 'ok' ]]; do
        read -p "Con el token enlazaremos los workers. Cópialo aparte y escribe 'ok': " token_saved
    done

    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config

    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
    curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
    sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.0.0.0\/16/g' custom-resources.yaml
    kubectl create -f custom-resources.yaml
}

setup_workers(){
    # WIP
    exit 1
    
    # kubeadm join 10.0.0.248:6443 --token aooq01.dxpkfsrigssiydb9 \
    #         --discovery-token-ca-cert-hash sha256:7c233c5b632c22ba0ef3a6c1f2cb6137e05fa7e1b681773c5006b9080b7df76d
}

# ---

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

if true; then
    prepare_systems
    setup_k8s_docker_containerd

    case $(hostname) in
        SRV-SETE05-001)
            setup_master
            ;;
        *)
            setup_workers
            ;;
    esac
fi

