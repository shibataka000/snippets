provider "google" {
  project = "shibataka000-dev-277404"
}

terraform {
  backend "gcs" {
    bucket = "sbtk-tfstate"
    prefix = "snippets/gcp/gke.tf"
  }
}

data "google_container_engine_versions" "asia_northeast1_a" {
  location       = var.location
  version_prefix = "1.18."
}

resource "google_container_cluster" "sandbox" {
  name                     = "sandbox"
  location                 = var.location
  initial_node_count       = 1
  remove_default_node_pool = true

  min_master_version = data.google_container_engine_versions.asia_northeast1_a.latest_master_version
  node_version       = data.google_container_engine_versions.asia_northeast1_a.latest_node_version
}

resource "google_container_node_pool" "sandbox" {
  name       = "node-pool"
  location   = var.location
  cluster    = google_container_cluster.sandbox.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "n1-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "null_resource" "credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.sandbox.name} --zone ${google_container_cluster.sandbox.location}"
  }
  depends_on = [google_container_cluster.sandbox]
}

resource "null_resource" "cluster_admin_binding" {
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)"
  }
  depends_on = [null_resource.credentials]
}
