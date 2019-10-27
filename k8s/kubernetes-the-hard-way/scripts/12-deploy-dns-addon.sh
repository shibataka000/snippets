#!/bin/sh

echo "==================== Deploying the DNS Cluster Add-on ===================="

kubectl apply -f https://storage.googleapis.com/kubernetes-the-hard-way/coredns.yaml

kubectl get pods -l k8s-app=kube-dns -n kube-system

echo "==================== Verification ===================="

kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600
kubectl get pods -l run=busybox
POD_NAME=$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti $POD_NAME -- nslookup kubernetes
