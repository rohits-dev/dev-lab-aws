
module fluxcd {
    source = "./fluxcd"
    count = var.ADD_FLUXCD ? 1: 0
    depends_on = [
        module.eks,
        module.vpn]
    github_owner = var.GITHUB_OWNER
    repository_name = var.REPOSITORY_NAME
    repository_visibility = "private"
    branch = var.BRANCH
    target_path = var.TARGET_PATH
    
}

module "autoscaler" {
    source = "./autoscaler"
    depends_on = [
        module.eks, 
        module.fluxcd, 
        module.vpn]
    aws_region = var.AWS_REGION
    resource_prefix = var.RESOURCE_PREFIX
    
    github_owner = var.GITHUB_OWNER
    repository_name = var.REPOSITORY_NAME
    branch = var.BRANCH
    target_path = var.TARGET_PATH
    eks_oidc_provider = module.eks.oidc_provider
    eks_oidc_provider_arn = module.eks.oidc_provider_arn
    
}

module "external_dns" {
    source = "./external-dns"
    depends_on = [
        module.eks, 
        module.fluxcd, 
        module.vpn]
    aws_region = var.AWS_REGION
    resource_prefix = var.RESOURCE_PREFIX
    
    github_owner = var.GITHUB_OWNER
    repository_name = var.REPOSITORY_NAME
    branch = var.BRANCH
    target_path = var.TARGET_PATH
    eks_oidc_provider = module.eks.oidc_provider
    eks_oidc_provider_arn = module.eks.oidc_provider_arn
    route_53_zone_id = aws_route53_zone.main.zone_id
    route_53_zone_arn = aws_route53_zone.main.arn
}

module vault {
    source = "./vault"
    count = var.ADD_FLUXCD ? 1: 0
    depends_on = [
        module.eks, 
        module.fluxcd, 
        module.vpn]
    aws_region = var.AWS_REGION
    resource_prefix = var.RESOURCE_PREFIX
    root_ca_crt = tls_self_signed_cert.root_ca.cert_pem
    root_ca_key = tls_private_key.root_ca.private_key_pem
    github_owner = var.GITHUB_OWNER
    repository_name = var.REPOSITORY_NAME
    branch = var.BRANCH
    target_path = var.TARGET_PATH
    eks_oidc_provider = module.eks.oidc_provider
    eks_oidc_provider_arn = module.eks.oidc_provider_arn
}



