
output "root_ca_cert_pem" {
  value = tls_self_signed_cert.root_ca.cert_pem
}

output "root_ca_private_key_pem" {
  value = tls_private_key.root_ca.private_key_pem
}


output "root_ca_acm_arn" {
  value = aws_acm_certificate.root_certificate.arn
}
