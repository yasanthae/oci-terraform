output "vpc_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = var.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = google_compute_subnetwork.private[*].id
}

output "private_subnet_names" {
  description = "List of names of private subnets"
  value       = google_compute_subnetwork.private[*].name
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = google_compute_subnetwork.public[*].id
}

output "public_subnet_names" {
  description = "List of names of public subnets"
  value       = google_compute_subnetwork.public[*].name
}

output "nat_gateway_ids" {
  description = "List of Cloud NAT IDs"
  value       = google_compute_router_nat.nat[*].id
}

output "router_ids" {
  description = "List of Cloud Router IDs"
  value       = google_compute_router.router[*].id
}