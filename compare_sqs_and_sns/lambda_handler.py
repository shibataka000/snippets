# coding: utf-8

from __future__ import print_function

import json

import boto3

print('Loading function')


def subscribe_sqs(event, context):
    sqs = boto3.resource("sqs")
    queue = sqs.get_queue_by_name(QueueName="test")
    print("start receive")
    for message in queue.receive_messages():
        print(message.body)
        message.delete()
    print("finish receive")


def subscribe_sns(event, context):
    message = json.loads(event["Records"][0]["Sns"]["Message"])
    message = json.dumps(message, indent=4)
    print(message)
