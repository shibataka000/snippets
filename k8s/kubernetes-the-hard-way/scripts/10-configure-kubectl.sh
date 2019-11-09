#!/bin/sh

echo "==================== The Admin Kubernetes Configuration File ===================="

KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers --names kubernetes-the-hard-way | jq -r ".LoadBalancers[0].DNSName")

kubectl config set-cluster kubernetes-the-hard-way \
     --certificate-authority=ca.pem \
     --embed-certs=true \
     --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \
     --client-certificate=admin.pem \
     --client-key=admin-key.pem

kubectl config set-context kubernetes-the-hard-way \
     --cluster=kubernetes-the-hard-way \
     --user=admin

kubectl config use-context kubernetes-the-hard-way

echo "==================== Verification ===================="

kubectl get componentstatuses
kubectl get nodes
