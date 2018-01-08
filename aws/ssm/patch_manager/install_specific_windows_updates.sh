#!/bin/sh
INSTANCE_ID=`terraform output instance_id`
KB_ARTICLE_IDS=KB4052303
aws ssm send-command --document-name "AWS-InstallSpecificWindowsUpdates" --instance-ids $INSTANCE_ID --parameters "{\"KbArticleIds\":[\"$KB_ARTICLE_IDS\"]}" --timeout-seconds 600 --region ap-northeast-1
