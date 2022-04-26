output "eks_cluster_name" {
    description = "Name of the EKS Cluster"
    value = local.cluster_name
}

output "vault_url" {
    description = "Url of the Vault Cluster"
    value = "vault.${var.RESOURCE_PREFIX}.local"
}

output "vault_s3_bucket" {
    description = "Name of the S3 bucket for vault"
    value = "s3://${var.RESOURCE_PREFIX}-vault/vault/vault_secret.json"
}


output "aws_region" {
    description = "Region in which resources were deployed"
    value = var.AWS_REGION
}
