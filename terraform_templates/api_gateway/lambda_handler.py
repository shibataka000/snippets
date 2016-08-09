# coding: utf-8

from __future__ import print_function

import json
import datetime

import boto3

print('Loading function')


def receive(event, context):
    now = datetime.datetime.now()
    tmpfile = "/tmp/event"
    with open(tmpfile, "w") as fout:
        fout.write(json.dumps(event, indent=4))
    s3 = boto3.client("s3")
    key = now.strftime("%Y%m%d-%H%M%S.txt")
    s3.upload_file(tmpfile, 'sbtk-output', key)
