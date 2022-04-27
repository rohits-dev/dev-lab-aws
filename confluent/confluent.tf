resource "kubernetes_namespace" "confluent" {
  metadata {
    name = "confluent"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

}