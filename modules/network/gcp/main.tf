################################################################################
# GCP VPC Module
################################################################################

locals {
  network_name = "${var.project_name}-${var.environment}-vpc"
}

resource "google_compute_network" "vpc" {
  name                    = local.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

################################################################################
# Subnets
################################################################################

resource "google_compute_subnetwork" "private" {
  count = length(var.private_subnet_cidrs)
  
  name          = "${local.network_name}-private-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
    private_ip_google_access = true
  
  # Secondary ranges for GKE pods and services - only for first subnet
  dynamic "secondary_ip_range" {
    for_each = count.index == 0 ? [1] : []
    content {
      range_name    = "gke-pods"
      ip_cidr_range = "10.0.160.0/20"  # Keep existing range from first subnet
    }
  }
  
  dynamic "secondary_ip_range" {
    for_each = count.index == 0 ? [1] : []
    content {
      range_name    = "gke-services"
      ip_cidr_range = "10.0.200.0/24"  # Keep existing range from first subnet
    }
  }
  
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "public" {
  count = length(var.public_subnet_cidrs)
  
  name          = "${local.network_name}-public-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

################################################################################
# Cloud Router (for NAT)
################################################################################

resource "google_compute_router" "router" {
  count = var.enable_nat_gateway ? 1 : 0
  
  name    = "${local.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

################################################################################
# Cloud NAT
################################################################################

resource "google_compute_router_nat" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  
  name                               = "${local.network_name}-nat"
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  
  dynamic "subnetwork" {
    for_each = google_compute_subnetwork.private
    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

################################################################################
# Firewall Rules
################################################################################

# Allow internal communication
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.network_name}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.vpc_cidr]
}

# Allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.network_name}-allow-health-checks"
  network = google_compute_network.vpc.name
  project = var.project_id
  
  allow {
    protocol = "tcp"
  }
  
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["gke-node"]
}