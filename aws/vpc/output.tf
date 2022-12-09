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

output "public_subnets" {
  value = local.public_subnets
}

output "vpc_id" {
  value = local.vpc_id
}
