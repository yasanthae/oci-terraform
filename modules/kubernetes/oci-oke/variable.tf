variable "cluster_name" {
  description = "Name of the OKE cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
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

variable "vcn_id" {
  description = "VCN OCID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet OCIDs"
  type        = list(string)
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
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}