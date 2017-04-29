# coding: utf-8

import argparse
import base64

import boto3

key_id = "90eccedd-2f4d-43fa-8073-cf553dd92d35"


def encrypt(plaintext):
    client = boto3.client("kms")
    encrypted_data = client.encrypt(
        KeyId=key_id,
        Plaintext=plaintext
    )
    ciphertext = encrypted_data["CiphertextBlob"]
    ciphertext = base64.b64encode(ciphertext)
    return ciphertext


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("plaintext")
    args = parser.parse_args()

    ciphertext = encrypt(args.plaintext)
    print(ciphertext)
