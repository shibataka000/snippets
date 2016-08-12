# coding: utf-8

from __future__ import print_function

import json
import datetime

import boto3

print('Loading function')


def run(event, context):
    now = datetime.datetime.now()
    now_str = now.strftime("%Y/%m/%d %H:%M:%S")
    print(now_str)
