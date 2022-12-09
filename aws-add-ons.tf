module "eks" {
  source                                = "./aws/eks"
  resource_prefix                       = var.RESOURCE_PREFIX
  vpc_id                                = local.vpc_id
  aws_auth_roles                        = var.AWS_AUTH_ROLES
  aws_auth_users                        = var.AWS_AUTH_USERS
  aws_region                            = var.AWS_REGION
  private_subnets_name_filter           = var.PRIVATE_SUBNETS_NAME_FILTER
  add_eks_public_access                 = var.ADD_EKS_PUBLIC_ACCESS
  cluster_additional_security_group_ids = [module.vpn.vpn_security_group_id]
  arm_or_amd                            = var.ARM_OR_AMD
  cluster_name                          = local.cluster_name
  private_subnets                       = local.private_subnets
  vpc_cidr_block                        = local.vpc_cidr_block
}
