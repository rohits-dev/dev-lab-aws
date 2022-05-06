resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "cert-manager"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

}

resource "kubernetes_secret" "certmanager_tls_ca_crt" {
  depends_on = [kubernetes_namespace.certmanager]

  metadata {
    name      = "tls-ca"
    namespace = "cert-manager"
  }

  data = {
    "tls.crt" = var.root_ca_crt
    "tls.key" = var.root_ca_key
  }
  type = "kubernetes.io/tls"
}

resource "kubernetes_service_account" "vault_issuer" {
  metadata {
    name      = "vault-issuer"
    namespace = "cert-manager"
  }
}

data "template_file" "vault_issuer_patch" {
  template = file("${path.module}/k8s_patches/vault-issuer-patch.yaml")
  vars = {
    resource_prefix               = var.resource_prefix
    service_account_default_token = kubernetes_service_account.vault_issuer.default_secret_name
    ca_base64                     = base64encode(var.root_ca_crt)
  }
}

data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

resource "github_repository_file" "vault_issuer_patch" {
  repository          = data.github_repository.main.name
  file                = "resources/cert-manager/vault-issuer-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.vault_issuer_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}
