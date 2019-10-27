#!/bin/sh

echo "==================== Add records to /etc/hosts ===================="

for instance in controller-0 controller-1 controller-2 worker-0 worker-1 worker-2; do
    EXTERNAL_DNS=$(aws ec2 describe-instances --filters Name=tag:Name,Values=${instance} Name=instance-state-name,Values=running | jq -r ".Reservations[0].Instances[0].PublicDnsName")
    for i in 0 1 2; do
        ssh ${EXTERNAL_DNS} "echo \"10.240.0.1${i} controller-${i}\" | sudo tee -a /etc/hosts"
    done
    for i in 0 1 2; do
        ssh ${EXTERNAL_DNS} "echo \"10.240.0.2${i} worker-${i}\" | sudo tee -a /etc/hosts"
    done
done
