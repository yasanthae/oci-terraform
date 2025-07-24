################################################################################
# OCI Additional Services Module - Variables
################################################################################

variable "compartment_id" {
  description = "OCI Compartment ID"
  type        = string
}

variable "environment" {
  description = "Development environment"
  type        = string
}

variable "project_name" {
  description = "LOLC OKE"
  type        = string
}

variable "region" {
    description = "OCI Region (Singapore)"
    type        = string
    default     = "ap-singapore-1"
}

variable "availability_domain" {
  description = "Availability Domain for resources"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Subnet ID for compute instances"
  type        = string
  default     = ""
}

variable "vcn_id" {
  description = "VCN ID for networking resources"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Block Volume Configuration
variable "block_volumes" {
  description = "Configuration for block volumes"
  type = map(object({
    size_in_gbs             = number
    vpus_per_gb             = number
    availability_domain     = string
    backup_policy_enabled   = bool
  }))
  default = {}
}

# Object Storage Configuration
variable "object_storage_buckets" {
  description = "Configuration for object storage buckets"
  type = map(object({
    access_type     = string
    storage_tier    = string
    versioning      = string
  }))
  default = {}
}

# Queue Configuration
variable "queues" {
  description = "Configuration for OCI Queues"
  type = map(object({
    visibility_timeout_in_seconds = number
    message_retention_period     = number
    dead_letter_queue_delivery_count = number
  }))
  default = {}
}

# Virtual Machine Configuration
variable "virtual_machines" {
  description = "Configuration for virtual machines"
  type = map(object({
    shape               = string
    shape_config        = object({
      ocpus         = number
      memory_in_gbs = number
    })
    availability_domain = string
    boot_volume_size_in_gbs = number
    boot_volume_vpus_per_gb = number
    image_id           = string
    operating_system   = string
  }))
  default = {}
}

# Database Configuration
variable "database_systems" {
  description = "Configuration for database systems"
  type = map(object({
    shape               = string
    shape_config        = object({
      ocpus = number
    })
    database_edition    = string
    db_name             = string
    db_admin_password   = string
    availability_domain = string
    storage_size_in_gbs = number
    storage_vpus_per_gb = number
  }))
  default = {}
}
