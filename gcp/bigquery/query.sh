#!/bin/bash
QUERY="SELECT distinct userIdentity.arn, userAgent, sourceIPAddress, eventSource, eventName FROM sample.sample WHERE date(eventTime) = '2018-11-01' ORDER BY arn"
echo "$QUERY"
bq --location="US" query --use_legacy=false --dry_run "$QUERY"
bq --location="US" query --use_legacy=false "$QUERY"
