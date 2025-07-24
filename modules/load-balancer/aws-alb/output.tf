output "lb_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = module.lb_role.iam_role_arn
}

output "controller_status" {
  description = "Status of the AWS Load Balancer Controller"
  value       = length(helm_release.alb_controller) > 0 ? helm_release.alb_controller[0].status : "Not deployed"
}

output "controller_namespace" {
  description = "Namespace where the controller is deployed"
  value       = length(helm_release.alb_controller) > 0 ? helm_release.alb_controller[0].namespace : "Not deployed"
}

output "controller_version" {
  description = "Version of the AWS Load Balancer Controller"
  value       = length(helm_release.alb_controller) > 0 ? helm_release.alb_controller[0].version : "Not deployed"
}