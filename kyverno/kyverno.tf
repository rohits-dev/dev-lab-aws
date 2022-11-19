resource "kubernetes_namespace" "kyverno" {
  metadata {
    name = "kyverno"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    command    = <<EOT
    kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
    kubectl delete mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg

    EOT
    on_failure = continue
  }

}
