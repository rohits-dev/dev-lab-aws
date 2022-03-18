#Generate Root CA
resource "tls_private_key" "root_ca" {
  algorithm   = "RSA"
}

resource "local_file" "root_ca_key" {
    content =  tls_private_key.root_ca.private_key_pem
    filename = "generated_certs/root_ca.key"
}

resource "tls_self_signed_cert" "root_ca" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.root_ca.private_key_pem

  subject {
    common_name  = "${var.RESOURCE_PREFIX}.local"
    organization = "My Local, Inc"
  }

  validity_period_hours = 8760 #1 year
  is_ca_certificate = true
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}
resource "local_file" "root_ca_crt" {
    content =  tls_self_signed_cert.root_ca.cert_pem
    filename = "generated_certs/root_ca.crt"

    # provisioner "local-exec" {
    #   command = "sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./generated_certs/root_ca.crt"
    # }
    # provisioner "local-exec" {
    #   when    = destroy
    #   command = "sudo security remove-trusted-cert -d  ./generated_certs/root_ca.crt "
    # }
}

resource "aws_acm_certificate" "root_certificate" {
  private_key      = tls_private_key.root_ca.private_key_pem
  certificate_body = tls_self_signed_cert.root_ca.cert_pem
  
}