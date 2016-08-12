# coding: utf-8

from __future__ import print_function

import json
import subprocess

import boto3

print('Loading function')


def run(event, context):
    output = subprocess.check_output(
        "echo test | openssl base64", shell=True
    )
    print(output)
