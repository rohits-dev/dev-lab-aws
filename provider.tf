
terraform {
  required_version = ">= 1.2.3"
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
      version = ">= 4.0.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 4.6.3"
    }

  }
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      environment       = "DEV"
      divvy_owner       = var.OWNER_EMAIL
      owner_name        = var.GITHUB_OWNER
      owner_email       = var.OWNER_EMAIL
      owner_github_repo = "https://github.com/${var.GITHUB_OWNER}"
      project           = "LAB"
      ManagedBy         = "Terraform"
    }
  }
  ignore_tags {
    keys = ["divvy_last_modified_by", "divvy_owner"]
  }
}

provider "flux" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    # token                  = data.aws_eks_cluster_auth.cluster_auth.token
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
      command     = "aws"
    }
  }
  git = {
    url = "https://github.com/${var.GITHUB_OWNER}/${var.REPOSITORY_NAME}.git"
    http = {
      username = "git" # This can be any string when using a personal access token
      password = var.GITHUB_TOKEN
    }
    branch = var.BRANCH
  }
}

provider "kubectl" {

}



provider "okta" {
  org_name       = var.OKTA_ORG_ID
  base_url       = "okta.com"
  client_id      = var.OKTA_CLIENT_ID
  private_key_id = var.OKTA_PRIVATE_KEY_ID
  private_key    = var.OKTA_PRIVATE_KEY
  scopes         = ["okta.apps.manage"]
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
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name]
    command     = "aws"
  }

}

provider "github" {
  owner = var.GITHUB_OWNER
  token = var.GITHUB_TOKEN
}
