resource "flux_bootstrap_git" "this" {

  embedded_manifests = true
  path               = var.target_path
}

resource "kubernetes_config_map" "resource-prefix" {
  depends_on = [ flux_bootstrap_git.this ]
  metadata {
    name = "resource-prefix"
    namespace = "flux-system"
  }

  data = {
    prefix = var.resource_prefix
  }

  binary_data = {
    "my_payload.bin" = "${filebase64("${path.module}/my_payload.bin")}"
  }
}