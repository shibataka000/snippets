# coding: utf-8

from __future__ import print_function

import json
import time

import boto3

print('Loading function')


def send(event, context):
    sqs = boto3.resource("sqs")
    queue = sqs.get_queue_by_name(QueueName="test")
    for i in range(100):
        queue.send_message(MessageBody=str(i))
        _lambda = boto3.client("lambda")
        _lambda.invoke(
            FunctionName="receive",
            InvocationType="Event"
        )


def receive(event, context):
    sqs = boto3.resource("sqs")
    queue = sqs.get_queue_by_name(QueueName="test")
    print("start receive")
    for message in queue.receive_messages():
        print(message.body)
        time.sleep(5)
        message.delete()
    print("finish receive")
