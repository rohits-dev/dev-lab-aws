
module fluxcd{
    source = "./fluxcd"
    depends_on = [module.eks, aws_ec2_client_vpn_endpoint.client_vpn,
    aws_ec2_client_vpn_authorization_rule.auth_rule,
    aws_ec2_client_vpn_network_association.subnet_association]
    github_owner = var.GITHUB_OWNER
    repository_name = var.REPOSITORY_NAME
    repository_visibility = "private"
    branch = var.BRANCH
    target_path = var.TARGET_PATH
    
}

module vault{
    source = "./vault"
    depends_on = [module.eks, module.fluxcd, 
    aws_ec2_client_vpn_endpoint.client_vpn, 
    
    aws_ec2_client_vpn_authorization_rule.auth_rule,
    aws_ec2_client_vpn_network_association.subnet_association]
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

