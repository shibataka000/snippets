# CloudFront log analysis

Analyze CloudFront log by elasticsearch and kibana.
See [CloudFrontのアクセスログをKibanaで可視化する ｜ Developers.IO](https://dev.classmethod.jp/server-side/elasticsearch/cloudfront-log-to-kibana/) more detail.

## Prerequisite
- CloudFront log exist in S3 Bucket.

## Execution procedure

### Setup Elasticsearch Service
- Create Elasticsearch Service domain.

### Setup Logstash instance
- Create EC2 instance.
    - OS: Ubuntu 16.04
    - Instance type: t2.medium
- Install Logstash and Logstash plugin.
    - Run [install_logstash.sh](install_logstash.sh) on EC2 instance.
- Create `cloudfront-logstash.conf`.
    - Fill in the following parameters on [cloudfront-logstash.conf](cloudfront-logstash.conf)
        - `<CLOUDFRONT_LOG_BUCKET>`
        - `<CLOUDFRONT_LOG_KEY_PREFIX>`
        - `<BUCKET_REGION_NAME>`
        - `<AMAZON_ES_DOMAIN_ENDPOINT>`
        - `<AMAZON_ES_DOMAIN_REGION_NAME>`
    - Copy [cloudfront-logstash.conf](cloudfront-logstash.conf) to `/hone/ubuntu/cloudfront-logstash.conf`.
- Create `cloudfront.template.json`.
    - Copy [cloudfront.template.json](cloudfront.template.json) to `/home/ubuntu/cloudfront.template.json`.
- Set credentials to this instance.
    - Use IAM role or credentials file.
- Make sure this instance can communicate with Elasticsearch.
    - Check security group setting.

### Transfer CloudFront log from S3 to Elasticsearch
- Run `sudo /usr/share/logstash/bin/logstash -f /home/ubuntu/cloudfront-logstash.conf`
- Delete `/usr/share/logstash/data/plugins/inputs/s3/sincedb_*` if you want to tranfer all log from the beggining.

TODO: I can't transfer CloudFront log from S3 to Elasticsearch ... Why?

### View data by Kibana
- SSH Logstash instance with portforwarding.
    - Because Kibana can be accessed from instance in same VPC.
    - Run `ssh ubuntu@<ES2_INSTANCE_PUBLIC_DNS_NAME> -L 1443:<AMAZON_ES_DOMAIN_ENDPOINT>:443`
- Access https://localhost:1443/_plugin/kibana/ .
- Create `cloudfront-logs-*` index.

## Author
[shibataka000](https://github.com/shibataka000)
