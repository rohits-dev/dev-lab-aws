
resource "tls_private_key" "vpn_server" {
  algorithm   = "RSA"
}

resource "tls_cert_request" "vpn_server" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.vpn_server.private_key_pem

  subject {
    common_name  = "vpn-server"
    organization = "My Local, Inc"
  }
  dns_names = ["vpn-server"]
  
}
resource "tls_locally_signed_cert" "vpn_server" {
  cert_request_pem   = tls_cert_request.vpn_server.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = var.root_ca_key
  ca_cert_pem        = var.root_ca_crt
  validity_period_hours = 8760 #1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}
resource "local_file" "vpn_server_crt" {
    content =  tls_locally_signed_cert.vpn_server.cert_pem
    filename = "generated_certs/vpn-server.crt"
}

resource "local_file" "vpn_server_key" {
    content =  tls_private_key.vpn_server.private_key_pem
    filename = "generated_certs/vpn-server.key"
}


resource "aws_acm_certificate" "vpn_server_crt" {
  private_key      = tls_private_key.vpn_server.private_key_pem
  certificate_body = tls_locally_signed_cert.vpn_server.cert_pem
  certificate_chain = var.root_ca_crt
}

# client certificate


resource "tls_private_key" "vpn_client" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "vpn_client" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.vpn_client.private_key_pem

  subject {
    common_name  = "vpn-client"
    organization = "My Local, Inc"
  }
  dns_names = [ "vpn-client"]
}
resource "tls_locally_signed_cert" "vpn_client" {
  cert_request_pem   = tls_cert_request.vpn_client.cert_request_pem
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = var.root_ca_key
  ca_cert_pem        = var.root_ca_crt
  validity_period_hours = 8760 #1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth"
  ]
}
resource "local_file" "vpn_client_crt" {
    content =  tls_locally_signed_cert.vpn_client.cert_pem
    filename = "generated_certs/vpn-client.crt"
}
resource "local_file" "vpn_client_key" {
    content =  tls_private_key.vpn_client.private_key_pem
    filename = "generated_certs/vpn-client.key"
}
