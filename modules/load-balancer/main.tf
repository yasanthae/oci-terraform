################################################################################
# Multi-Cloud Load Balancer Module
################################################################################

locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "load-balancer"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

################################################################################
# AWS ALB Controller
################################################################################

module "aws_alb" {
  source = "./aws-alb"
  count  = var.cloud_provider == "aws" ? 1 : 0
  
  cluster_name      = var.cluster_name
  region            = var.region
  vpc_id            = var.vpc_id
  oidc_provider_arn = var.oidc_provider_arn
  
  tags = local.common_tags
}

################################################################################
# GCP Load Balancer (uses native GKE ingress controller)
################################################################################

module "gcp_lb" {
  source = "./gcp-lb"
  count  = var.cloud_provider == "gcp" ? 1 : 0
  
  cluster_name = var.cluster_name
  project_id   = var.gcp_project_id
  region       = var.region
  
  tags = local.common_tags
}

################################################################################
# OCI Load Balancer - Temporarily commented out
################################################################################

# module "oci_lb" {
#   source = "./oci-lb"
#   count  = var.cloud_provider == "oci" ? 1 : 0
#   
#   cluster_name   = var.cluster_name
#   cluster_id     = var.cluster_id
#   compartment_id = var.oci_compartment_id
#   
#   tags = local.common_tags
# }
