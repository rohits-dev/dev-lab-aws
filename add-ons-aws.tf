
module "vpc" {
  source                      = "./aws/vpc"
  resource_prefix             = var.RESOURCE_PREFIX
  cluster_name                = local.cluster_name
  vpc_id                      = var.VPC_ID
  aws_region                  = var.AWS_REGION
  private_subnets_name_filter = var.PRIVATE_SUBNETS_NAME_FILTER
}

module "eks" {
  source                                = "./aws/eks"
  resource_prefix                       = var.RESOURCE_PREFIX
  vpc_id                                = module.vpc.vpc_id
  aws_region                            = var.AWS_REGION
  private_subnets_name_filter           = var.PRIVATE_SUBNETS_NAME_FILTER
  add_eks_public_access                 = var.ADD_EKS_PUBLIC_ACCESS
  cluster_additional_security_group_ids = [module.vpn.vpn_security_group_id]
  arm_or_amd                            = var.ARM_OR_AMD
  cluster_name                          = local.cluster_name
  private_subnets                       = module.vpc.private_subnets
  vpc_cidr_block                        = module.vpc.vpc_cidr_block
  aws_eks_access_entries                = var.AWS_EKS_ACCESS_ENTRIES
}

module "vpn" {
  source          = "./aws/vpn"
  vpc_id          = module.vpc.vpc_id
  a_subnet_id     = module.vpc.public_subnets[0]
  vpc_cidr_block  = module.vpc.vpc_cidr_block
  root_ca_crt     = module.root_ca.root_ca_cert_pem
  root_ca_key     = module.root_ca.root_ca_private_key_pem
  root_ca_acm_arn = module.root_ca.root_ca_acm_arn
  resource_prefix = var.RESOURCE_PREFIX
}

module "root_ca" {
  source          = "./aws/root_ca"
  resource_prefix = var.RESOURCE_PREFIX
}
