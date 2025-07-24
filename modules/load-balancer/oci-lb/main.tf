# OCI Load Balancer Configuration

resource "oci_load_balancer_load_balancer" "main" {
  compartment_id = var.compartment_id
  display_name   = "${var.cluster_name}-lb"
  shape          = var.load_balancer_shape
  subnet_ids     = var.subnet_ids
  
  is_private = var.is_private
  
  freeform_tags = var.tags
}

# Backend set for the load balancer
resource "oci_load_balancer_backend_set" "main" {
  name             = "${var.cluster_name}-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  policy           = "ROUND_ROBIN"
  
  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/health"
  }
}

# Listener for the load balancer
resource "oci_load_balancer_listener" "main" {
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = "${var.cluster_name}-listener"
  default_backend_set_name = oci_load_balancer_backend_set.main.name
  port                     = 80
  protocol                 = "HTTP"
}
