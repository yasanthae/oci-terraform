variable "cloud_provider" {
  description = "The cloud provider to use"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "cluster_id" {
  description = "ID of the Kubernetes cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC/VCN ID"
  type        = string
}

# AWS Specific
variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
  default     = ""
}

# GCP Specific
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = ""
}

# OCI Specific
variable "oci_compartment_id" {
  description = "OCI Compartment ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}