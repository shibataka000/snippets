# Run Lambda by cron

Snippets to run Lambda function repeatedly.

## Description
Snippets create Lambda function and CloudWatch event.
CloudWatch event occurs every 5 minute and it invoke Lambda function.

## Install
```
$ zip lambda_with_cron.zip *.py
$ terraform apply
```

## Reference
- [Using AWS Lambda with Scheduled Events](https://docs.aws.amazon.com/lambda/latest/dg/with-scheduled-events.html)

## Author
[shibataka000](https://github.com/shibataka000)
