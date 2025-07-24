variable "cluster_name" {
  description = "Name of the OKE cluster"
  type        = string
}

variable "cluster_id" {
  description = "ID of the OKE cluster"
  type        = string
}

variable "compartment_id" {
  description = "OCI compartment ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for load balancer"
  type        = list(string)
  default     = []
}

variable "load_balancer_shape" {
  description = "Shape of the load balancer"
  type        = string
  default     = "flexible"
}

variable "is_private" {
  description = "Whether the load balancer is private"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
