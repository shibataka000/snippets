# coding: utf-8

import boto3
import os
import base64


def run(event, context):
    client = boto3.client("kms")
    ciphertext = os.environ["NAME"]
    ciphertext = base64.b64decode(ciphertext)
    plaintext = client.decrypt(CiphertextBlob=ciphertext)["Plaintext"]
    print("Hello {}!".format(plaintext))
