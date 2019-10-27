#!/bin/bash

REMOTE_SCRIPTS=$1

for i in 0 1 2; do
    instance=worker-${i}
    echo "==================== Bootstrapping the Kubernetes Worker Nodes in ${instance} ===================="
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    POD_CIDR=10.200.${i}.0/24
    scp $REMOTE_SCRIPTS/09-bootstrap-kubernetes-workers.sh ${EXTERNAL_DNS}:~/
    ssh $EXTERNAL_DNS bash 09-bootstrap-kubernetes-workers.sh $instance $POD_CIDR
done

echo "==================== Verification ===================="
for instance in controller-0 controller-1 controller-2; do
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    ssh $EXTERNAL_DNS kubectl get nodes --kubeconfig admin.kubeconfig
done
