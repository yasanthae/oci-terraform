variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VCN"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones (not used in OCI, but kept for consistency)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}