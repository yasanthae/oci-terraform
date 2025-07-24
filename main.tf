################################################################################
# Multi-Cloud Infrastructure Root Module
################################################################################

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    # oci = {
    #   source  = "oracle/oci"
    #   version = ">= 5.0"
    # }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
  }
}

################################################################################
# Provider Configuration
################################################################################

# AWS Provider
provider "aws" {
  region  = var.region
  profile = var.aws_profile
  
  skip_credentials_validation = var.cloud_provider != "aws"
  skip_requesting_account_id  = var.cloud_provider != "aws"
  skip_metadata_api_check     = var.cloud_provider != "aws"
  skip_region_validation      = var.cloud_provider != "aws"
}

# GCP Provider
provider "google" {
  project = var.gcp_project_id != "" ? var.gcp_project_id : "dummy-project"
  region  = var.region
  zone    = var.gcp_zone != "" ? var.gcp_zone : "us-central1-a"
}

# Oracle Cloud Provider - Temporarily commented out for GCP-only deployment
# provider "oci" {
#   # Use config file approach instead of direct parameters
#   # This allows us to use a dummy config file when not deploying to OCI
#   config_file_profile = "DEFAULT"
#   config_file_path    = "C:\\temp\\dummy_oci_config"
# }

################################################################################
# Network Module
################################################################################

module "network" {
  source = "./modules/network"
  
  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  region         = var.region
  
  # Network Configuration
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  
  # GCP Specific
  gcp_project_id = var.gcp_project_id
  
  # OCI Specific
  oci_compartment_id = var.oci_compartment_id
  
  tags = var.tags
}

################################################################################
# Kubernetes Cluster Module
################################################################################

module "kubernetes" {
  source = "./modules/kubernetes"
  
  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  region         = var.region
  
  # Cluster Configuration
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
    # Network Configuration from Network Module
  vpc_id              = module.network.vpc_id
  vpc_name            = module.network.vpc_name
  private_subnet_ids  = module.network.private_subnet_ids
  
  # Node Configuration
  node_groups = var.node_groups
  
  # AWS Specific
  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users
  
  # GCP Specific
  gcp_project_id = var.gcp_project_id
  
  # OCI Specific
  oci_compartment_id = var.oci_compartment_id
  
  tags = var.tags
  
  depends_on = [module.network]
}

################################################################################
# Kubernetes Provider Configuration (After Cluster Creation)
################################################################################

provider "kubernetes" {
  host                   = module.kubernetes.cluster_endpoint
  cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
  
  # AWS EKS
  dynamic "exec" {
    for_each = var.cloud_provider == "aws" ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.kubernetes.cluster_name]
    }
  }
  
  # GCP GKE
  token = var.cloud_provider == "gcp" ? module.kubernetes.cluster_token : null
  
  # OCI OKE
  # OKE uses similar exec authentication as EKS
  dynamic "exec" {
    for_each = var.cloud_provider == "oci" ? [1] : []
    content {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "oci"
      args = [
        "ce", "cluster", "generate-token",
        "--cluster-id", module.kubernetes.cluster_id,
        "--region", var.region
      ]
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.kubernetes.cluster_endpoint
    cluster_ca_certificate = base64decode(module.kubernetes.cluster_ca_certificate)
    token                  = var.cloud_provider == "gcp" ? module.kubernetes.cluster_token : null
  }
}

################################################################################
# Load Balancer Module
################################################################################

module "load_balancer" {
  source = "./modules/load-balancer"
  
  cloud_provider = var.cloud_provider
  environment    = var.environment
  project_name   = var.project_name
  region         = var.region
  
  # Cluster Configuration
  cluster_name = module.kubernetes.cluster_name
  cluster_id   = module.kubernetes.cluster_id
  
  # Network Configuration
  vpc_id = module.network.vpc_id
  
  # AWS Specific
  oidc_provider_arn = module.kubernetes.oidc_provider_arn
  
  # GCP Specific
  gcp_project_id = var.gcp_project_id
  
  # OCI Specific
  oci_compartment_id = var.oci_compartment_id
  
  tags = var.tags  
  depends_on = [module.kubernetes]
}