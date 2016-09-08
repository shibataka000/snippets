# CloudWatch Alarm

Snippets to catch alarm caused by Lambda or SQS.

## Description


## Requirement
- terraform

## Usage

### Catch alarm caused by Lambda
Invoke Lambda function `raise_exception` in AWS Management Console.
Then Lambda function `catch_alarm` will be invoked.
You can see it by CloudWatch log.

### Catch alarm caused by SQS
Send message to SQS queue `queue` .
After 15 seconds, Lambda function `catch_alarm` will be invoked because metric `age of old message` get `ALARM`.
You can see it by CloudWatch log.

## Install
```
$ zip cloudwatch_alarm.zip *
$ terraform apply
```

## Author
[shibataka000](https://github.com/shibataka000)
