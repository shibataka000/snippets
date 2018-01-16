import os
import json

import boto3


def issue_updated(event, context):
    body = json.loads(event["body"])
    client = boto3.client("sqs")
    queue_url = os.environ["SQS_QUEUE_URL"]
    issue_key = body["issue"]["key"]
    message_body = issue_key
    client.send_message(
        QueueUrl=queue_url,
        MessageBody=message_body
    )
    return {
        "statusCode": 200,
        "body": ""
    }
