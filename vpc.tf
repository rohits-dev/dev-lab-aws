data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

locals {
  cluster_name = "${var.RESOURCE_PREFIX}-eks-1"
}


module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.RESOURCE_PREFIX}-vpc-1"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "vpn" {
  source          = "./vpn"
  vpc_id          = module.vpc.vpc_id
  a_subnet_id     = module.vpc.public_subnets[0]
  vpc_cidr_block  = module.vpc.vpc_cidr_block
  root_ca_crt     = tls_self_signed_cert.root_ca.cert_pem
  root_ca_key     = tls_private_key.root_ca.private_key_pem
  root_ca_acm_arn = aws_acm_certificate.root_certificate.arn
}
