# Embulk

Embulk Getting Started.
See [Scheduled bulk data loading to Elasticsearch + Kibana 4 from CSV files](http://www.embulk.org/docs/recipe/scheduled-csv-load-to-elasticsearch-kibana4.html) for more information.

## Requirement
- terraform

## Getting Started

### Setup Elasticsearch and Kibana
Setup EC2 instance, and install Elasticsearch and Kibana.

```
terraform apply
```

Run Elasticsearch and Kibana.

```
/elasticsearch-5.2.1/bin/elasticsearch &
/kibana-5.2.1-linux-x86_64/bin/kibana &
```

### Setup Embulk, Loading a CSV file
See [Scheduled bulk data loading to Elasticsearch + Kibana 4 from CSV files](http://www.embulk.org/docs/recipe/scheduled-csv-load-to-elasticsearch-kibana4.html#setup-embulk) for more information.

## Author
[shibataka000](https://github.com/shibataka000)
