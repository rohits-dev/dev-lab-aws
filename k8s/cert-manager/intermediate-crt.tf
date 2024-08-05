# Generate Client Certificate

resource "tls_private_key" "cert_mgr_int_certificate" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cert_mgr_int_certificate" {
  private_key_pem = tls_private_key.cert_mgr_int_certificate.private_key_pem

  subject {
    common_name  = "cert_mgr_int"
    organization = "My Local, Inc"
  }

}
resource "tls_locally_signed_cert" "cert_mgr_int_certificate" {
  cert_request_pem      = tls_cert_request.cert_mgr_int_certificate.cert_request_pem
  ca_private_key_pem    = var.root_ca_key
  ca_cert_pem           = var.root_ca_crt
  validity_period_hours = 1
  is_ca_certificate     = true
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
    "crl_signing"
  ]
}
resource "local_file" "cert_mgr_int_crt" {
  content  = tls_locally_signed_cert.cert_mgr_int_certificate.cert_pem
  filename = "generated_certs/cert_mgr_int.crt"
}
resource "local_file" "cert_mgr_int_key" {
  content  = tls_private_key.cert_mgr_int_certificate.private_key_pem
  filename = "generated_certs/cert_mgr_int.key"
}
