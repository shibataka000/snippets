provider "google" {
  project = "numeric-haven-216005"
}

terraform {
  backend "gcs" {
    bucket = "sbtk-tfstate"
    prefix = "snippets/k8s/gke.tf"
  }
}

resource "google_container_cluster" "sandbox" {
  name = "sandbox"
  zone = "asia-northeast1-a"
  initial_node_count = 3
}

resource "null_resource" "credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.sandbox.name} --zone ${google_container_cluster.sandbox.zone}"
  }
}
