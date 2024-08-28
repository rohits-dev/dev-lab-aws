resource "kubernetes_config_map" "external-dns-vars" {
  metadata {
    name = "external-dns-vars"
    namespace = "flux-system"
  }

  data = {
    external_dns_iam_role_arn = aws_iam_role.external_dns.arn
  }
}