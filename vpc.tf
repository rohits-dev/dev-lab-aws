data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "existing_vpc" {
  count = var.VPC_ID == null ? 0 : 1
  id    = var.VPC_ID
}

data "aws_subnets" "private_subnets" {
  count = var.VPC_ID == null ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.VPC_ID]
  }
  filter {
    name   = "tag:Name"
    values = var.PRIVATE_SUBNETS_NAME_FILTER
  }
}

data "aws_subnets" "public_subnets" {
  count = var.VPC_ID == null ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.VPC_ID]
  }
  filter {
    name   = "tag:Name"
    values = var.PUBLIC_SUBNETS_NAME_FILTER
  }
}

locals {
  cluster_name    = "${var.RESOURCE_PREFIX}-eks-1"
  az_zone_ids     = data.aws_availability_zones.available.zone_ids
  vpc_id          = var.VPC_ID == null ? module.vpc[0].vpc_id : var.VPC_ID
  vpc_cidr_block  = var.VPC_ID == null ? module.vpc[0].vpc_cidr_block : data.aws_vpc.existing_vpc[0].cidr_block
  private_subnets = var.VPC_ID == null ? module.vpc[0].private_subnets : data.aws_subnets.private_subnets[0].ids
  public_subnets  = var.VPC_ID == null ? module.vpc[0].public_subnets : data.aws_subnets.public_subnets[0].ids
}



module "vpc" {
  count                = var.VPC_ID == null ? 1 : 0
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
  source          = "./aws/vpn"
  vpc_id          = local.vpc_id
  a_subnet_id     = local.public_subnets[0]
  vpc_cidr_block  = local.vpc_cidr_block
  root_ca_crt     = tls_self_signed_cert.root_ca.cert_pem
  root_ca_key     = tls_private_key.root_ca.private_key_pem
  root_ca_acm_arn = aws_acm_certificate.root_certificate.arn
}
