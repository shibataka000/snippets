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
  name               = "sandbox"
  location           = "asia-northeast1-a"
  initial_node_count = 3

  node_config {
    machine_type = "n1-standard-2"
  }
}

resource "null_resource" "credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.sandbox.name} --zone ${google_container_cluster.sandbox.zone}"
  }
  depends_on = [google_container_cluster.sandbox]
}

resource "null_resource" "cluster_admin_binding" {
  provisioner "local-exec" {
    command = "kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$(gcloud config get-value core/account)"
  }
  depends_on = [null_resource.credentials]
}
