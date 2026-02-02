#!/usr/bin/env bash
set -e

echo "[1/7] Dependências básicas"
apt update
apt install -y \
  ca-certificates curl conntrack socat \
  docker.io apt-transport-https

systemctl enable --now docker

echo "[2/7] kubectl (bypass TLS)"
curl -k -LO https://dl.k8s.io/release/$(curl -k -L https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
install -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

echo "[3/7] minikube (bypass TLS)"
curl -k -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

echo "[4/7] Subindo minikube"
minikube start \
  --driver=docker \
  --container-runtime=containerd \
  --kubernetes-version=stable \
  --insecure-registry="0.0.0.0/0"

echo "[5/7] Namespace AWX"
kubectl create namespace awx || true

echo "[6/7] AWX Operator"
kubectl apply -f https://raw.githubusercontent.com/ansible/awx-operator/devel/deploy/awx-operator.yaml \
  --insecure-skip-tls-verify

echo "[7/7] Criando AWX"
cat <<EOF | kubectl apply -n awx -f -
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
spec:
  service_type: nodeport
  admin_user: admin
  admin_password_secret: awx-admin-password
EOF

echo
echo "AGUARDE 3–5 MINUTOS"
echo "Depois rode:"
echo "  kubectl get pods -n awx"
echo
echo "Para pegar a senha:"
echo "  kubectl get secret awx-admin-password -n awx -o jsonpath='{.data.password}' | base64 -d"
echo
echo "Para acessar:"
echo "  minikube service awx-service -n awx"
