################################################################################
# AWS Load Balancer Controller
################################################################################

locals {
  lb_controller_name = "aws-load-balancer-controller"
  namespace          = "kube-system"
}

################################################################################
# IAM Role for Service Account (IRSA)
################################################################################

module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.cluster_name}-alb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${local.namespace}:${local.lb_controller_name}"]
    }
  }

  tags = var.tags
}

################################################################################
# Kubernetes Service Account
################################################################################

resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = local.lb_controller_name
    namespace = local.namespace
    labels = {
      "app.kubernetes.io/name"      = local.lb_controller_name
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

################################################################################
# Helm Release for AWS Load Balancer Controller
################################################################################

resource "helm_release" "alb_controller" {
  count = 0  # Temporarily disabled - deploy infrastructure first

  name       = local.lb_controller_name
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = local.namespace
  version    = "1.6.2"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = kubernetes_service_account.alb_controller.metadata[0].name
    },
    {
      name  = "image.repository"
      value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
    }
  ]

  depends_on = [
    kubernetes_service_account.alb_controller
  ]
}