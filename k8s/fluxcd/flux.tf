resource "flux_bootstrap_git" "this" {

  embedded_manifests = true
  path               = var.target_path
}
