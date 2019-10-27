#!/bin/bash

REMOTE_SCRIPTS=$1

for instance in controller-0 controller-1 controller-2; do
    echo "==================== Bootstrapping the Kubernetes Control Plane in ${instance} ===================="
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    scp $REMOTE_SCRIPTS/08-bootstrap-kubernetes-controllers.sh ${EXTERNAL_DNS}:~/
    ssh $EXTERNAL_DNS bash 08-bootstrap-kubernetes-controllers.sh
done

echo "==================== Verification ===================="
KUBERNETES_PUBLIC_ADDRESS=$(aws elbv2 describe-load-balancers --names kubernetes-the-hard-way | jq -r ".LoadBalancers[0].DNSName")
curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
