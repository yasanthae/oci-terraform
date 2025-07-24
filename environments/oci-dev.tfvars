################################################################################
# Oracle Cloud Development Environment Configuration
################################################################################

# Cloud Provider
cloud_provider = "oci"

# Common Configuration
environment  = "dev"
project_name = "multicloud"
region       = "us-ashburn-1"

# Tags
tags = {
  Environment = "dev"
  Project     = "multicloud"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = []  # OCI uses ADs differently, will be auto-detected
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true  # OCI NAT Gateway is regional

# Kubernetes Configuration
cluster_name       = "multicloud-dev-oke"
kubernetes_version = "v1.30.1"  # OCI uses v prefix

# Node Groups
node_groups = {
  general = {
    instance_types = ["VM.Standard.E4.Flex"]
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

# OCI Specific Configuration
oci_tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaa..."
oci_user_ocid        = "ocid1.user.oc1..aaaaaaaa..."
oci_fingerprint      = "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99"
oci_private_key_path = "~/.oci/oci_api_key.pem"
oci_compartment_id   = "ocid1.compartment.oc1..aaaaaaaa..."

# Backend Configuration (for reference - use backend config file)
backend_bucket = "terraform-state-multicloud-dev-oci"
backend_key    = "oci/dev/terraform.tfstate"
backend_region = "us-ashburn-1"