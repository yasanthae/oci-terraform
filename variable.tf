################################################################################
# Multi-Cloud Infrastructure Variables
################################################################################

################################################################################
# Cloud Provider Selection
################################################################################

variable "cloud_provider" {
  description = "The cloud provider to use (aws, gcp, oci)"
  type        = string
  validation {
    condition     = contains(["aws", "gcp", "oci"], var.cloud_provider)
    error_message = "Cloud provider must be one of: aws, gcp, oci"
  }
}

################################################################################
# Common Variables
################################################################################

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name to be used as a prefix for all resources"
  type        = string
  default     = "multicloud"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}

################################################################################
# Network Variables
################################################################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

################################################################################
# Kubernetes Cluster Variables
################################################################################

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
  default     = "1.30"
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = map(string)
    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    default = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      disk_size      = 50
      labels         = {}
      taints         = []
    }
  }
}

################################################################################
# AWS Specific Variables
################################################################################

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

variable "aws_auth_roles" {
  description = "List of IAM roles to add to aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of IAM users to add to aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

################################################################################
# GCP Specific Variables
################################################################################

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

variable "gcp_zone" {
  description = "GCP Zone for zonal resources"
  type        = string
  default     = ""
}

variable "gcp_service_account_email" {
  description = "Service account email for GKE nodes"
  type        = string
  default     = ""
}

################################################################################
# Oracle Cloud (OCI) Specific Variables
################################################################################

variable "oci_tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
  default     = ""
}

variable "oci_user_ocid" {
  description = "OCI User OCID"
  type        = string
  default     = ""
}

variable "oci_fingerprint" {
  description = "OCI API Key Fingerprint"
  type        = string
  default     = ""
}

variable "oci_private_key_path" {
  description = "Path to OCI API Private Key"
  type        = string
  default     = ""
}

variable "oci_compartment_id" {
  description = "OCI Compartment ID"
  type        = string
  default     = ""
}

################################################################################
# Backend Configuration Variables
################################################################################

variable "backend_bucket" {
  description = "S3/GCS/OCI bucket for Terraform state"
  type        = string
  default     = ""
}

variable "backend_key" {
  description = "Path/Key for Terraform state file"
  type        = string
  default     = "terraform.tfstate"
}

variable "backend_region" {
  description = "Region for backend bucket"
  type        = string
  default     = ""
}