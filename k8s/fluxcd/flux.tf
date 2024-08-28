# resource "flux_bootstrap_git" "this" {

#   embedded_manifests = true
#   path               = var.target_path
# }
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }
}

resource "kubernetes_config_map" "resource-prefix" {
  depends_on = [ kubernetes_namespace.flux_system ]
  metadata {
    name = "resource-prefix"
    namespace = "flux-system"
  }

  data = {
    resource_prefix = var.resource_prefix
  }
}

resource "helm_release" "flux2" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.12.4"

  name      = "flux2"
  namespace = "flux-system"

  depends_on = [kubernetes_namespace.flux_system]
}

resource "kubernetes_secret" "ssh_keypair" {
  metadata {
    name      = "ssh-keypair"
    namespace = "flux-system"
  }

  type = "Opaque"

  data = {
    "identity.pub" = var.git_ssh_public_key
    "identity"     = var.git_ssh_private_key
    "known_hosts"  = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }

  depends_on = [kubernetes_namespace.flux_system]
}

resource "helm_release" "flux2_sync" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2-sync"
  version    = "1.8.2"

  # Note: Do not change the name or namespace of this resource. The below mimics the behaviour of "flux bootstrap".
  name      = "flux-system"
  namespace = "flux-system"

  set {
    name  = "gitRepository.spec.url"
    value = "ssh://git@github.com/${var.github_owner}/${var.repository_name}.git"
  }

  set {
    name  = "gitRepository.spec.ref.branch"
    value = var.branch
  }

  set {
    name  = "gitRepository.spec.secretRef.name"
    value = kubernetes_secret.ssh_keypair.metadata[0].name
  }

  set {
    name  = "gitRepository.spec.interval"
    value = "1m"
  }

  depends_on = [helm_release.flux2]
}
