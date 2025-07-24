################################################################################
# Multi-Cloud Kubernetes Module
################################################################################

locals {
  common_tags = merge(
    var.tags,
    {
      module = "kubernetes"
    }
  )
}

################################################################################
# AWS EKS
################################################################################

module "aws_eks" {
  source = "./aws-eks"
  count  = var.cloud_provider == "aws" ? 1 : 0
  
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  region             = var.region
  
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids
  
  node_groups    = var.node_groups
  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users
  
  tags = local.common_tags
}

################################################################################
# GCP GKE
################################################################################

module "gcp_gke" {
  source = "./gcp-gke"
  count  = var.cloud_provider == "gcp" ? 1 : 0
  
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  project_id         = var.gcp_project_id
  region             = var.region
  
  vpc_name           = var.vpc_name
  private_subnet_ids = var.private_subnet_ids
  
  node_groups = var.node_groups
  
  tags = local.common_tags
}

################################################################################
# OCI OKE - Temporarily commented out
################################################################################

# module "oci_oke" {
#   source = "./oci-oke"
#   count  = var.cloud_provider == "oci" ? 1 : 0
#   
#   cluster_name       = var.cluster_name
#   kubernetes_version = var.kubernetes_version
#   compartment_id     = var.oci_compartment_id
#   region             = var.region
#   
#   vcn_id             = var.vpc_id
#   private_subnet_ids = var.private_subnet_ids
#   
#   node_groups = var.node_groups
#   
#   tags = local.common_tags
# }
