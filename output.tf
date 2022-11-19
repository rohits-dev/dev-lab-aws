output "eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = local.cluster_name
}

output "vault_url" {
  description = "Url of the Vault Cluster"
  value       = "vault.${var.RESOURCE_PREFIX}.local"
}

output "vault_s3_bucket" {
  description = "Name of the S3 bucket for vault"
  value       = "s3://${var.RESOURCE_PREFIX}-vault/vault/vault_secret.json"
}


output "aws_region" {
  description = "Region in which resources were deployed"
  value       = var.AWS_REGION
}

output "vpc_id" {
  description = "vpc id"
  value       = local.vpc_id
}

output "private_subnet_ids" {
  description = "subnet ids"
  value       = local.private_subnets
}

output "eks_has_public_access" {
  description = "Expose if EKS has public access"
  value       = var.ADD_EKS_PUBLIC_ACCESS
}

output "has_fluxcd" {
  description = "If EKS has services deployed"
  value       = var.ADD_FLUXCD
}
