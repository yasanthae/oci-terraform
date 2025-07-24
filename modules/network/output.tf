output "vpc_id" {
  description = "The ID of the VPC"
  value = coalesce(
    try(module.aws_network[0].vpc_id, ""),
    try(module.gcp_network[0].vpc_id, "")
    # try(module.oci_network[0].vcn_id, "")
  )
}

output "vpc_name" {
  description = "The name of the VPC"
  value = coalesce(
    try(module.aws_network[0].vpc_id, ""),  # AWS uses ID as name
    try(module.gcp_network[0].vpc_name, "")
    # try(module.oci_network[0].vcn_name, "")
  )
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value = coalesce(
    try(module.aws_network[0].vpc_cidr, ""),
    try(module.gcp_network[0].vpc_cidr, "")
    # try(module.oci_network[0].vcn_cidr, "")
  )
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = coalescelist(
    try(module.aws_network[0].private_subnet_ids, []),
    try(module.gcp_network[0].private_subnet_ids, [])
    # try(module.oci_network[0].private_subnet_ids, [])
  )
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = coalescelist(
    try(module.aws_network[0].public_subnet_ids, []),
    try(module.gcp_network[0].public_subnet_ids, [])
    # try(module.oci_network[0].public_subnet_ids, [])
  )
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value = coalescelist(
    try(module.aws_network[0].nat_gateway_ids, []),
    try(module.gcp_network[0].nat_gateway_ids, [])
    # try(module.oci_network[0].nat_gateway_ids, [])
  )
}