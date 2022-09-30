resource "aws_route53_zone" "main" {
  name          = "${var.RESOURCE_PREFIX}.local"
  force_destroy = true
  vpc {
    vpc_id = local.vpc_id
  }
}
