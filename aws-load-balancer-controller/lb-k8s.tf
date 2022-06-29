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
