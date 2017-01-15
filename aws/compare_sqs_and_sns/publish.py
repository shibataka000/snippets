# coding: utf-8

from __future__ import print_function

import boto3

MAX_COUNT = 100


def publish_to_sqs():
    sqs = boto3.resource("sqs")
    queue = sqs.get_queue_by_name(QueueName="test")
    for i in range(MAX_COUNT):
        queue.send_message(MessageBody=str(i))
        _lambda = boto3.client("lambda")
        _lambda.invoke(
            FunctionName="subscribe_sqs",
            InvocationType="Event"
        )


def publish_to_sns():
    sns = boto3.client("sns")
    for i in range(MAX_COUNT):
        sns.publish(
            TopicArn="arn:aws:sns:ap-northeast-1:370106426606:test",
            Message=str(i)
        )


if __name__ == "__main__":
    publish_to_sns()
    publish_to_sqs()
