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


resource "kubernetes_config_map" "vault-issuer-vars" {
  metadata {
    name = "vault-issuer-vars"
    namespace = "flux-system"
  }

  data = {
    ca_base64                     = base64encode(var.root_ca_crt)
  }
}
