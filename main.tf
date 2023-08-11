terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("./tf-seed-project-395602-7f6b048a00b9.json")

  project = "tf-seed-project-395602"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_subnetwork" "subnet-with-secondary-ranges" {
  name          = "terraform-subnetwork"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = "172.16.0.0/22"
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "172.16.4.0/22"
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "terraform-network"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_firewall" "terraform-firewall-resource" {
  name    = "terraform-firewall-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "terraform-firewall-resource-hc" {
  name    = "terraform-firewall-hc"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}

resource "google_compute_address" "public_ip_for_bastion" {
  name = "terraform-bastion-ip"
}

resource "google_service_account" "service_account_compute" {
  account_id   = "terraform-sa-compute-id"
  display_name = "terraform-sa-compute"
}
