
terraform {
  required_version = ">= 0.13"
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.13.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }

  }
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Environment = "DEV"
      Owner       = "https://github.com/${var.GITHUB_OWNER}"
      Project     = "LAB"
      ManagedBy   = "Terraform"
    }
  }
}

provider "flux" {}

provider "kubectl" {

}

data "aws_eks_cluster_auth" "cluster_auth" {
  depends_on = [module.eks]
  name       = local.cluster_name
}

provider "kubernetes" {

  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  # token                  = data.aws_eks_cluster_auth.cluster_auth.token
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }

}

provider "github" {
  owner = var.GITHUB_OWNER
  token = var.GITHUB_TOKEN
}
