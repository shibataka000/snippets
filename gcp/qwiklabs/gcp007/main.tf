provider "google" {
  project = "shibataka000-dev-277404"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

terraform {
  backend "gcs" {
    bucket = "sbtk-tfstate"
    prefix = "gcp/qwiklabs/gcp007.tf"
  }
}

# Web server instances
data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_instance_template" "nginx-template" {
  name         = "nginx-template"
  machine_type = "n1-standard-1"
  disk {
    source_image = "debian-cloud/debian-10"
  }
  network_interface {
    network = data.google_compute_network.default.name
    access_config {}
  }
  metadata_startup_script = file("startup.sh")
}

resource "google_compute_target_pool" "nginx-pool" {
  name = "nginx-pool"
}

resource "google_compute_instance_group_manager" "nginx-group" {
  name               = "nginx-group"
  base_instance_name = "nginx"
  version {
    instance_template = google_compute_instance_template.nginx-template.id
  }
  target_pools = [google_compute_target_pool.nginx-pool.id]
  target_size  = 2
  named_port {
    name = "nginx"
    port = 80
  }
}

resource "google_compute_firewall" "www-firewall" {
  name    = "www-firewall"
  network = data.google_compute_network.default.name
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# Network load balancer
resource "google_compute_forwarding_rule" "nginx-lb" {
  name       = "nginx-lb"
  target     = google_compute_target_pool.nginx-pool.id
  port_range = "80"
}

# Http load balancer
resource "google_compute_http_health_check" "http-basic-check" {
  name = "http-basic-check"
}

resource "google_compute_backend_service" "nginx-backend" {
  name          = "nginx-backend"
  protocol      = "HTTP"
  health_checks = [google_compute_http_health_check.http-basic-check.id]
  backend {
    group = google_compute_instance_group_manager.nginx-group.instance_group
  }
}

resource "google_compute_url_map" "web-map" {
  name            = "web-map"
  default_service = google_compute_backend_service.nginx-backend.id
}

resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.web-map.id
}

resource "google_compute_global_forwarding_rule" "http-content-rule" {
  name       = "http-content-rule"
  target     = google_compute_target_http_proxy.http-lb-proxy.id
  port_range = "80"
}

output "network-load-balancer" {
  value = google_compute_forwarding_rule.nginx-lb.ip_address
}

output "http-load-balancer" {
  value = google_compute_global_forwarding_rule.http-content-rule.ip_address
}
