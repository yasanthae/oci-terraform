################################################################################
# AWS Development Environment Configuration
################################################################################

# Cloud Provider
cloud_provider = "aws"

# Common Configuration
environment  = "dev"
project_name = "multicloud"
region       = "ap-south-1"

# Tags
tags = {
  Environment = "dev"
  Project     = "multicloud"
  ManagedBy   = "terraform"
  Owner       = "devops-team"
}

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true  # Cost optimization for dev

# Kubernetes Configuration
cluster_name       = "multicloud-dev-eks"
kubernetes_version = "1.30"

# Node Groups
node_groups = {
  general = {
    instance_types = ["t3.medium"]
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

# AWS Specific Configuration
aws_profile = "default"

# IAM Roles for EKS Access
aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::123456789012:role/DevOpsAdminRole"
    username = "devops-admin"
    groups   = ["system:masters"]
  }
]

aws_auth_users = []

# Backend Configuration (for reference - use backend config file)
backend_bucket = "terraform-state-multicloud-dev"
backend_key    = "aws/dev/terraform.tfstate"
backend_region = "ap-south-1"

# GCP Dummy Variables (not used for AWS deployment)
gcp_project_id = "dummy-project"
gcp_zone       = "us-central1-a"