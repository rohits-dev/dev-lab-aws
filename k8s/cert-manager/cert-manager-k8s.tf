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

resource "kubernetes_secret" "certmanager_tls_int_ca_crt" {
  depends_on = [kubernetes_namespace.certmanager]

  metadata {
    name      = "int-cert-tls"
    namespace = "cert-manager"
  }

  data = {
    "tls.crt" = format("%s\n%s", tls_locally_signed_cert.cert_mgr_int_certificate.cert_pem, var.root_ca_crt)
    "tls.key" = tls_private_key.cert_mgr_int_certificate.private_key_pem
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

resource "github_repository_file" "vault_issuer_patch" {
  repository          = var.repository_name
  file                = "cluster-resources/resources/cert-manager/vault-issuer-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.vault_issuer_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}
