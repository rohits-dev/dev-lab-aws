resource "aws_route53_zone" "main" {
  name          = "${var.resource_prefix}.local"
  force_destroy = true
  vpc {
    vpc_id = local.vpc_id
  }
}
