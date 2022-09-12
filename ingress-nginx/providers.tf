terraform {
  required_version = ">= 1.2.3"
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    # kubectl = {
    #   source  = "gavinbunney/kubectl"
    #   version = ">= 1.10.0"
    # }
  }
}
