resource "kubernetes_namespace" "confluent" {
  metadata {
    name = "confluent"
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
