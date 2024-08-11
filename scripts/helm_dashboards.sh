
install_helm(){
    cd /tmp
    curl -fsSL -O https://get.helm.sh/helm-v3.15.3-linux-amd64.tar.gz
    tar -zxvf helm-v3.*-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
    cd ~

    apt install jq
}

# helm_install_helm_dashboard(){
#     helm plugin install https://github.com/komodorio/helm-dashboard.git
#     helm plugin update dashboard
# }

# helm_dashboard_service(){
#     local_ip="$(ip --json a s | jq -r '.[] | if .ifname | test("^enX0$") then .addr_info[] | select(.family == "inet") | .local else empty end')"

#     tee /usr/local/bin/start-helm-dashboard.sh << EOF
# #!/usr/bin/env bash
# helm dashboard --bind=${local_ip}
# EOF
#     chmod +x /usr/local/bin/start-helm-dashboard.sh

#     tee /etc/systemd/system/helm-dashboard.service << EOF
# [Unit]
# Description=Helm Dashboard Service
# After=network.target

# [Service]
# ExecStartPre=/bin/sleep 20
# ExecStart=/usr/local/bin/start-helm-dashboard.sh
# Restart=always
# User=root

# [Install]
# WantedBy=multi-user.target
# EOF

#     systemctl daemon-reload
#     systemctl enable --now helm-dashboard
# }


helm_install_kubernetes_dashboard(){
  helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
  helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard --set kong.admin.tls.enabled=false
}

kubernetes_dashboard_service(){
    local_ip="$(ip --json a s | jq -r '.[] | if .ifname | test("^enX0$") then .addr_info[] | select(.family == "inet") | .local else empty end')"

    tee /usr/local/bin/start-kubernetes-dashboard.sh << EOF
#!/usr/bin/env bash
kubectl -n kubernetes-dashboard port-forward --address=${local_ip} svc/kubernetes-dashboard-kong-proxy 8443:443
EOF
    chmod +x /usr/local/bin/start-kubernetes-dashboard.sh

    tee /etc/systemd/system/kubernetes-dashboard.service << EOF
[Unit]
Description=Kubernetes Dashboard Service
After=network.target

[Service]
ExecStartPre=/bin/sleep 20
ExecStart=/usr/local/bin/start-kubernetes-dashboard.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now kubernetes-dashboard
}

kubernetes_dashboard_token(){

    if kubectl get serviceaccount -n kubernetes-dashboard | grep -q 'admin-user'; then
        echo "The 'admin-user' serviceaccount already exists. Terminating script..."
        exit 1
    fi

    kubectl apply -f - << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

    BEARER_TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
    echo $BEARER_TOKEN > /root/bearer_token
}

usage(){
    echo -e "\n============================================"
    echo "Ya deberíamos poder consultar los Dashboards directamente desde el anfitrión (no la vm)"
    echo "Kubernetes Dashboard: http://10.0.0.248:8443 (token en ~/bearer_token)"
    # echo "Helm Dashboard:       http://10.0.0.248:8080"
}

# ---

if true; then

    if ! helm &>/dev/null; then
        install_helm
    fi

    if ! helm &>/dev/null; then
        echo "Helm debería estar instalado. Terminando script."
        exit 1
    fi

    # if ! helm plugin list | grep -q foobar; then
    #     helm_install_helm_dashboard
    # fi

    # if [ ! -e /etc/systemd/system/helm-dashboard.service ] || [ ! -e /usr/local/bin/start-helm-dashboard.sh ]; then
    #     helm_dashboard_service
    # fi

    if ! helm list --namespace kubernetes-dashboard | grep -q kubernetes-dashboard; then
        helm_install_kubernetes_dashboard
    fi

    if [ ! -e /etc/systemd/system/kubernetes-dashboard.service ] || [ ! -e /usr/local/bin/start-kubernetes-dashboard.sh ]; then
        kubernetes_dashboard_service
    fi

    if [ ! -e /root/bearer_token ]; then
        kubernetes_dashboard_token
    fi

    usage
fi
