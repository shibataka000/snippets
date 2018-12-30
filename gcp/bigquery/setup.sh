#!/bin/bash
TMP_DIR=/tmp/sbtk-cloudtrail
MERGED_LOG_FILE=/tmp/merged.json
TRANSFORMED_LOG_FILE=/tmp/transformed.json
SCHEMA_FILE=/tmp/schema.json

rm -r $TMP_DIR $MERGED_LOG_FILE $TRANSFORMED_LOG_FILE $SCHEMA_FILE
terraform taint google_bigquery_table.sample

mkdir -p $TMP_DIR

echo "Dowload CloudTrail log files."
for i in `seq 1 3`
do
    aws s3 cp s3://sbtk-cloudtrail/AWSLogs/370106426606/CloudTrail/ap-northeast-1/2018/11/0${i} $TMP_DIR/0${i} --recursive --quiet
done

echo "Merge log files."
for gz_file in `find $TMP_DIR -type f`
do
    gzip -d $gz_file
    json_file=`echo $gz_file | awk '{sub("\.gz", "")} {print $0}'`
    cat $json_file | jq -c ".Records[]" >> $MERGED_LOG_FILE
done

echo "Transform log files."
python transform/main.py $MERGED_LOG_FILE $SCHEMA_FILE $TRANSFORMED_LOG_FILE

echo "Create BigQuery table."
terraform apply -auto-approve

echo "Load log files to BigQuery."
bq --location="US" load --source_format=NEWLINE_DELIMITED_JSON sample.sample $TRANSFORMED_LOG_FILE $SCHEMA_FILE
