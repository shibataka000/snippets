# AWS Batch

Sample of AWS Batch.
See [AWS Batch Preview Getting Started](http://qiita.com/shibataka000/items/5d1b4f2161d8cb4c60a9) to get more information.
It is written in Japanese

## Requirement
- awsclie
	- awscli must have `aws batch` subcommand. I use awscli 1.11.30.

## Setup

### Preparation
1. Create IAM roles.
	- AWS Batch Service Role
	- ECS Instance Role
	- (Option)Amazon EC2 Spot Fleet Role
1. Create key pair.
1. Create VPC.
1. Create Security Group.

### Create Compute Envirionment
```
aws batch create-compute-environment --cli-input-json file://compute_environment.json
```

### Create Job Queue
```
aws batch create-job-queue --cli-input-json file://job_queue.json
```

### Create Job Definition
```
aws batch register-job-definition --cli-input-json file://job_definition.json
```

### Submit Job
```
aws batch submit-job --cli-input-json file://job_scheduling.json
```

### Result
You can see ouput by CloudWatch.

## Author
[shibataka000](https://github.com/shibataka000)
