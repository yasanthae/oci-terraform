################################################################################
# OCI VCN Module
################################################################################

locals {
  vcn_name = "${var.project_name}-${var.environment}-vcn"
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = [var.vpc_cidr]
  display_name   = local.vcn_name
  dns_label      = replace(var.project_name, "-", "")
  
  freeform_tags = var.tags
}

################################################################################
# Internet Gateway
################################################################################

resource "oci_core_internet_gateway" "ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-ig"
  enabled        = true
  
  freeform_tags = var.tags
}

################################################################################
# NAT Gateway
################################################################################

resource "oci_core_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0
  
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-nat"
  
  freeform_tags = var.tags
}

################################################################################
# Service Gateway
################################################################################

data "oci_core_services" "services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "sg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-sg"
  
  services {
    service_id = data.oci_core_services.services.services[0].id
  }
  
  freeform_tags = var.tags
}

################################################################################
# Route Tables
################################################################################

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-public-rt"
  
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.ig.id
  }
  
  freeform_tags = var.tags
}

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-private-rt"
  
  dynamic "route_rules" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      destination       = "0.0.0.0/0"
      destination_type  = "CIDR_BLOCK"
      network_entity_id = oci_core_nat_gateway.nat[0].id
    }
  }
  
  route_rules {
    destination       = data.oci_core_services.services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sg.id
  }
  
  freeform_tags = var.tags
}

################################################################################
# Security Lists
################################################################################

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-public-sl"
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 22
      max = 22
    }
  }
  
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 80
      max = 80
    }
  }
  
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    
    tcp_options {
      min = 443
      max = 443
    }
  }
  
  freeform_tags = var.tags
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${local.vcn_name}-private-sl"
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  
  ingress_security_rules {
    protocol = "all"
    source   = var.vpc_cidr
  }
  
  freeform_tags = var.tags
}

################################################################################
# Subnets
################################################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

resource "oci_core_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.private_subnet_cidrs[count.index]
  display_name               = "${local.vcn_name}-private-${count.index + 1}"
  dns_label                  = "private${count.index + 1}"
  prohibit_public_ip_on_vnic = true
  route_table_id             = oci_core_route_table.private.id
  security_list_ids          = [oci_core_security_list.private.id]
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  
  freeform_tags = var.tags
}

resource "oci_core_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.vcn.id
  cidr_block                 = var.public_subnet_cidrs[count.index]
  display_name               = "${local.vcn_name}-public-${count.index + 1}"
  dns_label                  = "public${count.index + 1}"
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.public.id
  security_list_ids          = [oci_core_security_list.public.id]
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[count.index % length(data.oci_identity_availability_domains.ads.availability_domains)].name
  
  freeform_tags = var.tags
}