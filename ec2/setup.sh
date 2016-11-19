#!/bin/sh
terraform apply

INSTANCE_ID=`terraform show | awk '$1=="id" {print $3}'`
PUBLIC_IP=`terraform show | awk '$1=="public_ip" {print $3}'`
KEY=~/.ssh/ec2_default.pem

echo
echo -n "Wait EC2 instance status become OK ... "
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
echo "Done"
echo
echo "ssh -i $KEY ubuntu@$PUBLIC_IP "
echo
