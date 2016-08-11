# lambda\_with\_git

Pull private repository from GitHub by Lambda function.

## Development environment
- Ubuntu 16.04
- Python 2.7.12

## Requirement
- virtualenv
- terraform

## Usage
Run Lambda function by AWS console.
Lambda function run python script as same as following command

```
$ git pull git@github.com:your_account/your_private_repository.git
$ git update-server-info
```

and show `.git/info/refs`.

## Install

### Install package
```
$ sudo apt-get install python-dev libssl-dev
```

### Generate ssh key pair
```
$ ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/(username)/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

Regist public key (`id_rsa.pub`) to GitHub and move private key (`id_rsa`) to `./ssh` directory.

### Create deploy package
Add source code.

```
$ zip lambda_with_git.zip *.py
```

Add libraries.

```
$ virtualenv .
$ source bin/activate
$ pip install -r requirements.txt
$ cd lib/python2.7/site-packages
$ zip ../../../lambda_with_git.zip ./* -r
```

Add ssh private key.

```
$ chmod 777 ssh/id_rsa
$ zip lambda_with_git.zip ssh/id_rsa
```

Add shared libraries.

```
$ cp lib/python2.7/site-packages/.libs_cffi_backend/libffi-72499c49.so.6.0.4 .
$ cp /lib/x86_64-linux-gnu/libssl.so.1.0.0  .
$ cp /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 .
$ zip lambda_with_git.zip libffi-72499c49.so.6.0.4 libssl.so.1.0.0 libcrypto.so.1.0.0
```

### Create Lambda function
```
terraform apply
```

## Author
[shibataka000](https://github.com/shibataka000)
