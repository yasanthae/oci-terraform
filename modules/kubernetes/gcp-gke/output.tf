output "cluster_id" {
  description = "The name/id of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint for GKE control plane"
  value       = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
  value       = google_container_cluster.primary.master_auth[0].cluster_ca_certificate
}

output "cluster_token" {
  description = "Token to authenticate with the cluster"
  value       = data.google_client_config.default.access_token
  sensitive   = true
}

output "cluster_master_version" {
  description = "The current version of the master in the cluster"
  value       = google_container_cluster.primary.master_version
}

output "node_pools" {
  description = "List of node pool names"
  value       = [for np in google_container_node_pool.primary_nodes : np.name]
}

output "service_account_email" {
  description = "The email address of the node service account"
  value       = google_service_account.node_sa.email
}