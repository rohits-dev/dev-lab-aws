resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      # protected = "true"
    }

  }
  lifecycle {
    ignore_changes = [
      # metadata[0].labels,
    ]
  }

}
