provider "google" {
    project = var.project_id
    region = var.region
}

data "google_client_config" "provider" {}

# VPC
resource "google_compute_network" "vpc" {
    name = "${var.project_id}-vpc"
    auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
    name = "${var.project_id}-subnet"
    region = var.region
    network = google_compute_network.vpc.name
    ip_cidr_range = "10.10.0.0/24"
}

# GKE Cluster
resource "google_container_cluster" "primary" {
    name = "${var.project_id}-gke"
    location = var.region
    remove_default_node_pool = true
    initial_node_count = 1
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary_nodes" {
    name = "${google_container_cluster.primary.name}"
    location = var.region
    cluster = google_container_cluster.primary.name
    node_count = var.gke_num_nodes

    node_config {
        oauth_scopes = [
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
        ]

        labels = {
          env = var.project_id
        }

        machine_type = "n1-standard-1"
        tags = ["gke-node", "${var.project_id}-gke"]
        metadata = {
            disable-legacy-endpoints = "true"
        }
    }
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
    name             = "argocd"
    repository       = "https://argoproj.github.io/argo-helm"
    chart            = "argo-cd"
    namespace        = "argocd"
    create_namespace = true

    values = [
        file("../argocd/application.yaml")
    ]
}