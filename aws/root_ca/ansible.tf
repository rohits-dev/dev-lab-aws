

# Generate Client Certificate

resource "tls_private_key" "ansible" {
  algorithm = "RSA"
}

resource "tls_cert_request" "ansible" {
  private_key_pem = tls_private_key.ansible.private_key_pem

  subject {
    common_name  = "kafka"
    organization = "My Local, Inc"
  }
  dns_names = [
    "*.eu-west-2.compute.internal"
  ]
}
resource "tls_locally_signed_cert" "ansible" {
  cert_request_pem      = tls_cert_request.ansible.cert_request_pem
  ca_private_key_pem    = tls_private_key.root_ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.root_ca.cert_pem
  validity_period_hours = 8760
  is_ca_certificate     = false
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
    "server_auth"
  ]
}
resource "local_file" "cert_mgr_int_crt" {
  content  = tls_locally_signed_cert.ansible.cert_pem
  filename = "generated_certs/ansible.crt"
}
resource "local_file" "cert_mgr_int_key" {
  content  = tls_private_key.ansible.private_key_pem
  filename = "generated_certs/ansible.key"
}
