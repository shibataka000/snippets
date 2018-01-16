# Cost Explorer

See AWS costs by boto3.

## Demo

### Get used services in last year

#### Script
```python
services = get_services()
print(json.dumps(services, indent=4))
```

#### Result
```python
[
    "AWS CloudTrail",
    "AWS Key Management Service",
    "AWS Lambda",
    "Amazon API Gateway",
    "Amazon CloudFront",
    "Amazon DynamoDB",
    "Amazon EC2 Container Registry (ECR)",
    "Amazon ElastiCache",
    "Amazon Elastic Block Store",
    "Amazon Elastic Compute Cloud - Compute",
    "Amazon Elastic Load Balancing",
    "Amazon Elastic MapReduce",
    "Amazon Registrar",
    "Amazon Route 53",
    "Amazon Simple Notification Service",
    "Amazon Simple Queue Service",
    "Amazon Simple Storage Service",
    "AmazonCloudWatch",
    "Tax"
]
```

### Get cost on specific month

#### Script
```python
costs = get_cost(2017, 12, services)
print(json.dumps(costs, indent=4))
```

You can also specify tags.

#### Result
```python
{
    "Tax": 3.45,
    "Amazon Registrar": 0,
    "Amazon Route 53": 1.001408,
    "Amazon Elastic Block Store": 0.1503880729,
    "Amazon Elastic MapReduce": 6.295070026,
    "AWS CloudTrail": 0.0,
    "Amazon Simple Notification Service": 0.0,
    "Amazon Simple Storage Service": 0.0206210342,
    "Amazon DynamoDB": 0.0,
    "AmazonCloudWatch": 0.0,
    "Amazon EC2 Container Registry (ECR)": 0.00480624,
    "Amazon Elastic Compute Cloud - Compute": 34.8188052931,
    "Amazon API Gateway": 0,
    "Amazon ElastiCache": 0,
    "AWS Key Management Service": 0.999999984,
    "Amazon Simple Queue Service": 0.0,
    "Amazon CloudFront": 0,
    "Amazon Elastic Load Balancing": 0,
    "AWS Lambda": 0
}
```

## Requirement
- boto3>=1.5.15

## Install
```bash
python3 -m venv venv
. venv/bin/activate
pip install pip --upgrade
pip install -r requirements.txt
```

## Author
[shibataka000](https://github.com/shibataka000)
