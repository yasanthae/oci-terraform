output "cluster_id" {
  description = "The ID of the Kubernetes cluster"
  value = try(
    module.aws_eks[0].cluster_name,
    module.gcp_gke[0].cluster_id,
    null
  )
}

output "cluster_name" {
  description = "The name of the Kubernetes cluster"
  value = try(
    module.aws_eks[0].cluster_name,
    module.gcp_gke[0].cluster_name,
    null
  )
}

output "cluster_endpoint" {
  description = "Endpoint for Kubernetes API server"
  value = try(
    module.aws_eks[0].cluster_endpoint,
    module.gcp_gke[0].cluster_endpoint,
    null
  )
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data"
  value = try(
    module.aws_eks[0].cluster_ca_certificate,
    module.gcp_gke[0].cluster_ca_certificate,
    null
  )
  sensitive = true
}

output "cluster_token" {
  description = "Token to authenticate with cluster (GCP)"
  value = try(module.gcp_gke[0].cluster_token, "")
  sensitive = true
}

# AWS Specific Outputs
output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value = try(module.aws_eks[0].cluster_oidc_issuer_url, "")
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value = try(module.aws_eks[0].oidc_provider_arn, "")
}