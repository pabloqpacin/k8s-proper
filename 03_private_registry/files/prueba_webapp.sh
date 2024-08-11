#!/usr/bin/env bash

mkdir -p ~/k8s/sondas

tee ~/k8s/sondas/sonda-http.yaml << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-d
spec:
  selector:
    matchLabels:
      app: web
  replicas: 1
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: apache
        image: pabloqpacin/sonda-web:v1
        ports:
        - containerPort: 80
        livenessProbe:
          httpGet:
            path: /sonda.html
            port: 80
          initialDelaySeconds: 3
          periodSeconds: 3
---
apiVersion: v1
kind: Service
metadata:
  name: web-svc
  labels:
     app: web
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 30002
    protocol: TCP
  selector:
     app: web
EOF

kubectl apply -f ~/k8s/sondas/sonda-http.yaml

# watch kubectl get all

sleep 20 && \
    kubectl get deploy &&
    kubectl get pods &&
    kubectl get rs &&
    kubectl get svc

sleep 20 && \
curl localhost:30002

# xdg-open http://10.0.0.248:30002/
