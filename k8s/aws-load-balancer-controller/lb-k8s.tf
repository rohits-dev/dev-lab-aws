resource "kubernetes_service_account" "aws_load_balancer_controller" {
  depends_on = [
    aws_iam_role.aws_load_balancer_controller
  ]
  metadata {
    name      = local.service_account_name
    namespace = local.namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn" : aws_iam_role.aws_load_balancer_controller.arn
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_config_map" "lb-controller-vars" {
  metadata {
    name = "lb-controller-vars"
    namespace = "flux-system"
  }

  data = {
    eks_cluster_name = var.eks_cluster_name
    owner_name       = var.github_owner
    owner_email      = var.owner_email
  }
}
