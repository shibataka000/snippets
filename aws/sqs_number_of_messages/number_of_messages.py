# coding: utf-8

import boto3

if __name__ == "__main__":
    url = ("https://sqs.ap-northeast-1.amazonaws.com/370106426606/test")
    sqs = boto3.resource("sqs")
    queue = sqs.Queue(url)
    queue.load()
    for key in queue.attributes:
        print(key, queue.attributes[key])
