# lambda\_with\_sqs

Experiment how to communicate between Lambda function using SQS.

## Description
I try to make two Lambda functions communicating each other using SQS.
But I wonder that

When function A send message and invoke function B some times,
do some of invocation of function B receive same message?
And some messages are not received and remain in SQS?

As a result, some of invocation receive same message.
But all of message are received and no message reamin in SQS.

## Usage
Run Lambda function `send` by AWS console.

## Install
```
$ zip lambda_with_sqs.zip *.py
$ terraform apply
```

## Author
[shibataka000](https://github.com/shibataka000)
