################################################################################
# Network Outputs
################################################################################

output "vpc_id" {
  description = "The ID of the VPC/Network"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC/Network"
  value       = module.network.vpc_cidr
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.network.nat_gateway_ids
}

################################################################################
# Kubernetes Cluster Outputs
################################################################################

output "cluster_id" {
  description = "The ID/name of the Kubernetes cluster"
  value       = module.kubernetes.cluster_id
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value       = module.kubernetes.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the Kubernetes API server"
  value       = module.kubernetes.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.kubernetes.cluster_ca_certificate
  sensitive   = true
}

output "cluster_token" {
  description = "Token to authenticate with the cluster (GCP)"
  value       = module.kubernetes.cluster_token
  sensitive   = true
}

# AWS Specific
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.kubernetes.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider (AWS)"
  value       = module.kubernetes.oidc_provider_arn
}

################################################################################
# Load Balancer Outputs
################################################################################

output "load_balancer_role_arn" {
  description = "ARN of the load balancer controller IAM role (AWS)"
  value       = module.load_balancer.lb_role_arn
}

output "load_balancer_status" {
  description = "Status of the load balancer controller deployment"
  value       = module.load_balancer.lb_controller_status
}

################################################################################
# Connection Instructions
################################################################################

output "kubectl_config_cmd" {
  description = "Command to configure kubectl"
  value = {
    aws = var.cloud_provider == "aws" ? "aws eks update-kubeconfig --region ${var.region} --name ${module.kubernetes.cluster_name}" : null
    gcp = var.cloud_provider == "gcp" ? "gcloud container clusters get-credentials ${module.kubernetes.cluster_name} --zone ${var.gcp_zone} --project ${var.gcp_project_id}" : null
    oci = var.cloud_provider == "oci" ? "oci ce cluster create-kubeconfig --cluster-id ${module.kubernetes.cluster_id} --file $HOME/.kube/config --region ${var.region}" : null
  }
}