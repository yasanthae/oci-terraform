################################################################################
# GCP Development Environment Configuration
################################################################################

# Cloud Provider
cloud_provider = "gcp"

# Common Configuration
environment  = "dev"
project_name = "multicloud"
region       = "us-central1"

# Tags
tags = {
  environment = "dev"
  project     = "multicloud"
  managed-by  = "terraform"
  owner       = "devops-team"
}

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-central1-a", "us-central1-b", "us-central1-c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true  # NAT is regional in GCP

# Kubernetes Configuration
cluster_name       = "multicloud-dev-gke"
kubernetes_version = "1.30"

# Node Groups
node_groups = {
  general = {
    instance_types = ["e2-standard-2"]
    min_size       = 1
    max_size       = 3
    desired_size   = 2
    disk_size      = 50
    labels = {
      role = "general"
    }
    taints = []
  }
}

# GCP Specific Configuration
gcp_project_id            = "terraformproject-464104"  # Replace with your real project ID
gcp_zone                  = "us-central1-a"
gcp_service_account_email = ""  # Will be created by the module

# Backend Configuration (for reference - use backend config file)
backend_bucket = "terraform-state-multicloud-dev-gcp"
backend_key    = "gcp/dev/terraform.tfstate"
backend_region = "us-central1"