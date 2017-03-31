# coding: utf-8

import boto3
from boto3.dynamodb.conditions import Key

TABLE_NAME = "HTTP_Cache"
SAMPLE_KEY = "https://github.com/shibataka000/snippets?page=1"

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)

# put_item
table.put_item(
    Item={
        "url": SAMPLE_KEY,
        "cache": {
            "item1": "1",
            "item2": "2",
            "item3": "3"
        },
        "etag": "etag"
    }
)

# query
res = table.query(
    KeyConditionExpression=Key("url").eq(SAMPLE_KEY)
)
for row in res["Items"]:
    print row
