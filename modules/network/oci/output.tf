output "vcn_id" {
  description = "The OCID of the VCN"
  value       = oci_core_vcn.vcn.id
}

output "vcn_cidr" {
  description = "The CIDR block of the VCN"
  value       = oci_core_vcn.vcn.cidr_blocks[0]
}

output "private_subnet_ids" {
  description = "List of OCIDs of private subnets"
  value       = oci_core_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of OCIDs of public subnets"
  value       = oci_core_subnet.public[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway OCIDs"
  value       = oci_core_nat_gateway.nat[*].id
}

output "internet_gateway_id" {
  description = "The OCID of the Internet Gateway"
  value       = oci_core_internet_gateway.ig.id
}

output "service_gateway_id" {
  description = "The OCID of the Service Gateway"
  value       = oci_core_service_gateway.sg.id
}