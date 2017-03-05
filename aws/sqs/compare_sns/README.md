# Compate SQS and SNS

What is different between SQS and SNS?

## Hypothesis

If I send a lot of messages, SQS can deliver all messages but SNS lack some of messages?

## Experiment

First, Send 100 messages to SNS.
Set Lambda function as subscriber of SNS topic.

Next, Send 100 messages to SQS and invoke Lambda function.

Can Lambda function receive all messages?

### How to make experiment
```
terraform apply
python publish.py
```

## Result

First, SNS invoke Lambda function 100 times.
Lambda functions receive all messages.

Next, Lambda functions invoked to receive messages from SQS can receive 99 messages but can't receive 1 message.
And functions receive same massages some times (not only one time).

## Conclusion

In this experiment, SNS can receive all messages.
But I don't know SNS also can do if many publisher publish message many many times.

## Author

[shibataka000](https://github.com/shibataka000)
