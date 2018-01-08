#!/bin/sh
INSTANCE_ID=`terraform output instance_id`
SSH_KEY=$HOME/.ssh/ec2_default.pem
aws ec2 get-password-data --instance-id $INSTANCE_ID --priv-launch-key $SSH_KEY
