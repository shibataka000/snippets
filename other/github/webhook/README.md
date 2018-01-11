# GitHub Webhook

Sample code to receive GitHub webhook.

## Description
This code create endpoint using API Gateway and Lambda in AWS.
Endpoint write parameter passed by webhook to text file and put it to S3.
You can make sure webhook call endpoint and see parameter passed by webhook.

## Usage
1. Regist endpoint on API Gateway to GitHub webhook in some repository.
1. Run `git push` on that repository.
1. Endpoint write parameter passed by webhook to text file and put it to S3.
1. See parameter file in S3 using AWS console.

## Install
1. Run `zip -r github_webhook.zip ./*`
1. Run `terraform apply`. It show endpoint on API Gateway.

## Author
[shibataka000](https://github.com/shibataka000)
