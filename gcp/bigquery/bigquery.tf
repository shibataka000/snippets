provider "google" {
  project = "numeric-haven-216005"
}

terraform {
  backend "gcs" {
    bucket = "sbtk-tfstate"
    prefix = "snippets/gcp/bigquery"
  }
}

resource "google_bigquery_dataset" "sample" {
  dataset_id = "sample"
  location = "US"
}

resource "google_bigquery_table" "sample" {
  dataset_id = "${google_bigquery_dataset.sample.dataset_id}"
  table_id = "sample"
  schema = "${file("/tmp/schema.json")}"
  time_partitioning {
    type = "DAY"
    field = "eventTime"
  }
}
