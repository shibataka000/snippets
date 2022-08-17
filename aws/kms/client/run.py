# coding: utf-8

import boto3

key_id = "90eccedd-2f4d-43fa-8073-cf553dd92d35"

client = boto3.client("kms")

plaintext = "Hello World!"
encrypted_data = client.encrypt(
    KeyId=key_id,
    Plaintext=plaintext
)

ciphertext = encrypted_data["CiphertextBlob"]
decrepted_data = client.decrypt(
    CiphertextBlob=ciphertext
)
decrepted_plaintext = decrepted_data["Plaintext"]

print("Plaintext is \"{}\".".format(plaintext))
print("Decrepted plaintext is \"{}\".".format(decrepted_plaintext))
