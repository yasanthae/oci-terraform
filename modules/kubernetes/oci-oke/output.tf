output "cluster_id" {
  description = "The OCID of the OKE cluster"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "cluster_name" {
  description = "The name of the OKE cluster"
  value       = oci_containerengine_cluster.oke_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint for OKE control plane"
  value       = oci_containerengine_cluster.oke_cluster.endpoints[0].public_endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster"
  value       = base64decode(yamldecode(data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content).clusters[0].cluster.certificate-authority-data)
}

output "cluster_kubernetes_version" {
  description = "The version of Kubernetes running on the cluster"
  value       = oci_containerengine_cluster.oke_cluster.kubernetes_version
}

output "node_pool_ids" {
  description = "Map of node pool names to their OCIDs"
  value       = { for k, v in oci_containerengine_node_pool.oke_node_pool : k => v.id }
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = local_file.kubeconfig.filename
}