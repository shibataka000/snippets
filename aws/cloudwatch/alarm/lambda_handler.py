# coding: utf-8

from __future__ import print_function

import json
import datetime

import boto3

print('Loading function')


def raise_exception(event, context):
    1 / 0


def catch_alarm(event, context):
    print("Subject: {}".format(event["Records"][0]["Sns"]["Subject"]))
    print("Message: {}".format(event["Records"][0]["Sns"]["Message"]))
