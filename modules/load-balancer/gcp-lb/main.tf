# GCP Load Balancer Configuration
# This module configures GKE native ingress controller

resource "google_compute_global_address" "lb_ip" {
  name = "${var.cluster_name}-lb-ip"
}

# GKE cluster automatically provisions ingress controller
# Additional configurations can be added here as needed

resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  count = var.ssl_certificate_domains != null ? 1 : 0
  
  name = "${var.cluster_name}-ssl-cert"
  
  managed {
    domains = var.ssl_certificate_domains
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
