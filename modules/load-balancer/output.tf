output "lb_role_arn" {
  description = "ARN of the load balancer controller IAM role (AWS)"
  value       = try(module.aws_alb[0].lb_role_arn, "")
}

output "lb_controller_status" {
  description = "Status of the load balancer controller deployment"
  value = coalesce(
    try(module.aws_alb[0].controller_status, ""),
    try(module.gcp_lb[0].controller_status, "")
    # try(module.oci_lb[0].controller_status, "")
  )
}

output "lb_controller_namespace" {
  description = "Namespace where the load balancer controller is deployed"
  value = coalesce(
    try(module.aws_alb[0].controller_namespace, ""),
    try(module.gcp_lb[0].controller_namespace, "")
    # try(module.oci_lb[0].controller_namespace, "")
  )
}