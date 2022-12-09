
output "root_ca_cert_pem" {
  value = tls_self_signed_cert.root_ca.cert_pem
}

output "root_ca_private_key_pem" {
  value = tls_private_key.root_ca.private_key_pem
}

output "route_53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "route_53_arn" {
  value = aws_route53_zone.main.arn
}

output "private_subnets" {
  value = local.private_subnets
}

output "vpc_cidr_block" {
  value = local.vpc_cidr_block
}

output "root_ca_acm_arn" {
  value = aws_acm_certificate.root_certificate.arn
}

output "public_subnets" {
  value = local.public_subnets
}

output "vpc_id" {
  value = local.vpc_id
}
