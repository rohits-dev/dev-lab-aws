resource "kubernetes_namespace" "kyverno" {
  metadata {
    name = "kyverno"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

}
