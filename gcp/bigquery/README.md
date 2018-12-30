# BigQuery

Snippets about BigQuery

## Description
- [setup.sh](./setup.sh)
    - Create BigQuery dataset and table.
    - Load AWS CloudTrail logs to BigQuery from AWS S3.
- [transform](./transform)
    - Guess schema of AWS CloudTrail logs.
    - Transform AWS CloudTrail logs to load BigQuery.
- [query.sh](./query.sh)
    - post sample query to BigQuery.

## Requirement
- Python3
- Terraform

## Usage
```
pip install -r transform/requirements.txt
bash setup.sh
bash query.sh
```

## Author
[shibataka000](https://github.com/shibataka000)
