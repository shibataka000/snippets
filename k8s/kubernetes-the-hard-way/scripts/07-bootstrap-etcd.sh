#!/bin/bash

REMOTE_SCRIPTS=$1

for instance in controller-0 controller-1 controller-2; do
    echo "==================== Bootstrapping the etcd Cluster in ${instance} ===================="
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    scp $REMOTE_SCRIPTS/07-bootstrap-etcd.sh ${EXTERNAL_DNS}:~/
    ssh $EXTERNAL_DNS bash 07-bootstrap-etcd.sh $instance
done
