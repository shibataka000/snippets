#!/bin/sh
INSTANCE_ID=`terraform output instance_id`
aws ssm send-command --document-name "AWS-RunPatchBaseline" --instance-ids $INSTANCE_ID --parameters '{"Operation":["Scan"]}' --timeout-seconds 600 --region ap-northeast-1
