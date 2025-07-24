################################################################################
# Multi-Cloud Network Module
################################################################################

locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "network"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

################################################################################
# AWS VPC Resources
################################################################################

module "aws_network" {
  source = "./aws"
  count  = var.cloud_provider == "aws" ? 1 : 0
  
  project_name         = var.project_name
  environment          = var.environment
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}

################################################################################
# GCP VPC Resources
################################################################################

module "gcp_network" {
  source = "./gcp"
  count  = var.cloud_provider == "gcp" ? 1 : 0
  
  project_name         = var.project_name
  environment          = var.environment
  project_id           = var.gcp_project_id
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  tags                 = local.common_tags
}

################################################################################
# OCI VCN Resources - Temporarily commented out
################################################################################

# module "oci_network" {
#   source = "./oci"
#   count  = var.cloud_provider == "oci" ? 1 : 0
#   
#   project_name         = var.project_name
#   environment          = var.environment
#   compartment_id       = var.oci_compartment_id
#   region               = var.region
#   vpc_cidr             = var.vpc_cidr
#   availability_zones   = var.availability_zones
#   private_subnet_cidrs = var.private_subnet_cidrs
#   public_subnet_cidrs  = var.public_subnet_cidrs
#   enable_nat_gateway   = var.enable_nat_gateway
#   tags                 = local.common_tags
# }
