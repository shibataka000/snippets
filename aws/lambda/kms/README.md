# KMS

Snippets about Lambda Function using environment variables encrypted by KMS.

## Requirement
- terraform
- boto3

## Usage

### Generate CMK
1. Generate CustomerMasterKey (CMK) on KMS on your region by AWS Management Console.
1. Copy KeyID of the CMK to [encrypt.py](./encrypt.py).
1. Attach KeyUser of the CMK to LambdaExecutionRole written on [template.tf](./template.tf).

### Encrypt plaintext
1. `python encrypt.py plaintext`. It return ciphertext.
1. Copy ciphertext to [template.tf](./template.tf).

### Deploy Lambda Function
1. `zip project.zip *.py`
1. `terraform apply`

### Run Lambda Function
1. Run Lambda Function `kms_sample` by AWS Management Console.

## Author
[shibataka000](https://github.com/shibataka000)
