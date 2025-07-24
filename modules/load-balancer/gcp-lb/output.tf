output "load_balancer_ip" {
  description = "IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "ssl_certificate_id" {
  description = "ID of the SSL certificate"
  value       = var.ssl_certificate_domains != null ? google_compute_managed_ssl_certificate.ssl_cert[0].id : null
}

output "controller_status" {
  description = "Status of the load balancer controller (not applicable for GCP native LB)"
  value       = "GCP native load balancer - no controller required"
}

output "controller_namespace" {
  description = "Namespace of the load balancer controller (not applicable for GCP native LB)"
  value       = "gcp-native"
}
