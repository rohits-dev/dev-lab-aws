
module "fluxcd" {
  source                = "./k8s/fluxcd"
  count                 = var.ADD_FLUXCD ? 1 : 0
  github_owner          = var.GITHUB_OWNER
  repository_name       = var.REPOSITORY_NAME
  repository_visibility = "private"
  branch                = var.BRANCH
  target_path           = local.flux_target_path
  providers = {
    kubernetes = kubernetes
  }
}

module "autoscaler" {
  source = "./k8s/autoscaler"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
  module.vpn]
  aws_region      = var.AWS_REGION
  resource_prefix = var.RESOURCE_PREFIX

  github_owner          = var.GITHUB_OWNER
  repository_name       = var.REPOSITORY_NAME
  branch                = var.BRANCH
  target_path           = local.target_path
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn

}

module "external_dns" {
  source = "./k8s/external-dns"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
  module.vpn]
  aws_region      = var.AWS_REGION
  resource_prefix = var.RESOURCE_PREFIX

  github_owner          = var.GITHUB_OWNER
  repository_name       = var.REPOSITORY_NAME
  branch                = var.BRANCH
  target_path           = local.target_path
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
  route_53_zone_id      = module.vpc.route_53_zone_id
  route_53_zone_arn     = module.vpc.route_53_arn
}

module "vault" {
  source = "./k8s/vault"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
    module.external_dns,
  module.vpn]
  aws_region            = var.AWS_REGION
  resource_prefix       = var.RESOURCE_PREFIX
  root_ca_crt           = module.root_ca.root_ca_cert_pem
  root_ca_key           = module.root_ca.root_ca_private_key_pem
  github_owner          = var.GITHUB_OWNER
  repository_name       = var.REPOSITORY_NAME
  branch                = var.BRANCH
  target_path           = local.target_path
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

module "certmanager" {
  source = "./k8s/cert-manager"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
  module.vpn]

  root_ca_crt     = module.root_ca.root_ca_cert_pem
  root_ca_key     = module.root_ca.root_ca_private_key_pem
  resource_prefix = var.RESOURCE_PREFIX
  github_owner    = var.GITHUB_OWNER
  repository_name = var.REPOSITORY_NAME
  branch          = var.BRANCH
  target_path     = local.target_path
}

module "confluent" {
  source = "./k8s/confluent"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
  module.vpn]
}

module "kyverno" {
  source = "./k8s/kyverno"
  count  = var.ADD_FLUXCD ? 1 : 0
  depends_on = [
    module.eks,
    module.fluxcd,
  module.vpn]

}

module "prometheus" {
  source = "./k8s/prometheus"
  count  = var.ADD_FLUXCD ? 1 : 0
  providers = {
    kubernetes = kubernetes
  }
  resource_prefix = var.RESOURCE_PREFIX
  github_owner    = var.GITHUB_OWNER
  repository_name = var.REPOSITORY_NAME
  branch          = var.BRANCH
  target_path     = local.target_path
}

module "aws_load_balancer_controller" {
  source = "./k8s/aws-load-balancer-controller"
  count  = var.ADD_FLUXCD ? 1 : 0
  providers = {
    kubernetes = kubernetes
  }
  eks_cluster_name      = local.cluster_name
  resource_prefix       = var.RESOURCE_PREFIX
  github_owner          = var.GITHUB_OWNER
  owner_email           = var.OWNER_EMAIL
  repository_name       = var.REPOSITORY_NAME
  branch                = var.BRANCH
  target_path           = local.target_path
  eks_oidc_provider     = module.eks.oidc_provider
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

module "ingress_nginx" {
  source = "./k8s/ingress-nginx"
  count  = var.ADD_FLUXCD ? 1 : 0
  providers = {
    kubernetes = kubernetes
  }
  resource_prefix = var.RESOURCE_PREFIX
}


