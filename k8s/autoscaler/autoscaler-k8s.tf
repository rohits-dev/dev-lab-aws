resource "kubernetes_config_map" "autoscaler-vars" {
  metadata {
    name = "autoscaler-vars"
    namespace = "flux-system"
  }

  data = {
    autoscaler_iam_role_arn = aws_iam_role.cluster_autoscaler.arn
    aws_region              = var.aws_region
  }
}
