# Jira2SQS

Transfer Jira issue key to SQS when issue updated.

## Description

This is sample code about following.

- [AWS Serverless Application Model(AWS SAM)](https://github.com/awslabs/serverless-application-model) sample code
- Custom domain on API Gateway

## Deploy

### Deploy application
```
sam package --template-file template.yml --output-template-file serverless-output.yml --s3-bucket <bucket-name>
sam deploy --template-file serverless-output.yml --stack-name <stack-name> --capabilities CAPABILITY_IAM
```

### Register custom domain
1. Register domain by [Route53](https://console.aws.amazon.com/route53).
    - e.g. `shibataka000.com`
2. Requests Certificate by [AWS Certificate Manager](https://console.aws.amazon.com/acm/home?region=us-east-1#/).
    - Use us-east-1 region.
    - e.g. Domain name is `jira2sqs.shibataka000.com`
3. Create custom domain by [API Gateway](https://ap-northeast-1.console.aws.amazon.com/apigateway/home?region=ap-northeast-1#/custom-domain-names).
4. Create record set by [Route53](https://console.aws.amazon.com/route53).

### Register webhook to Jira

## Usage
When Jira issue get updated, issue key will be sent to SQS queue.

If you want to send issue key manually, run following command.

```
curl -X POST -H "Accept: application/json" -H "Content-type: application/json" -d '{"issue": {"key": "ISSUE-1"}}' https://<custom-domain>
```

## Destroy resources

### Unregister webhook on Jira

### Unregister custom domain
Do `Register custom domain` by reversed order.

### Destroy application
```
aws cloudformation delete-stack --stack-name <stack-name>
```

## Run test
Test will be failed because SQS queue does not exist.

### Lambda
```
sam local invoke PostFunction -e event.json
```

### API Gateway
```
sam local start-api
curl -X POST -H "Accept: application/json" -H "Content-type: application/json" -d '{"issue": {"key": "ISSUE-1"}}' http://127.0.0.1:3000
```

## Author
[shibataka000](https://github.com/shibataka000)
