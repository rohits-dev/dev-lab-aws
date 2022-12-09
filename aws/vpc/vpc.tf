data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

data "aws_vpc" "existing_vpc" {
  count = var.vpc_id == null ? 0 : 1
  id    = var.vpc_id
}

data "aws_subnets" "private_subnets" {
  count = var.vpc_id == null ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = var.private_subnets_name_filter
  }
}

data "aws_subnets" "public_subnets" {
  count = var.vpc_id == null ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = var.public_subnets_name_filter
  }
}

locals {
  az_zone_ids     = data.aws_availability_zones.available.zone_ids
  vpc_id          = var.vpc_id == null ? module.vpc[0].vpc_id : var.vpc_id
  vpc_cidr_block  = var.vpc_id == null ? module.vpc[0].vpc_cidr_block : data.aws_vpc.existing_vpc[0].cidr_block
  private_subnets = var.vpc_id == null ? module.vpc[0].private_subnets : data.aws_subnets.private_subnets[0].ids
  public_subnets  = var.vpc_id == null ? module.vpc[0].public_subnets : data.aws_subnets.public_subnets[0].ids
}



module "vpc" {
  count                = var.vpc_id == null ? 1 : 0
  source               = "terraform-aws-modules/vpc/aws"
  name                 = "${var.resource_prefix}-vpc-1"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}


