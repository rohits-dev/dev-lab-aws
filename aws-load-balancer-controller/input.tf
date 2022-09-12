variable "resource_prefix" {
  nullable = false
}
variable "eks_cluster_name" {
  nullable = false
}

variable "github_owner" {
  type        = string
  description = "github owner"
  nullable    = false
}

variable "repository_name" {
  type        = string
  description = "github repository name"
  nullable    = false
}

variable "branch" {
  type        = string
  nullable    = false
  description = "branch name"
}


variable "target_path" {
  type        = string
  nullable    = false
  description = "flux sync target path"
}

variable "eks_oidc_provider_arn" {
  type        = string
  description = "eks oidc provider arn"
  nullable    = false
}

variable "eks_oidc_provider" {
  type        = string
  description = "eks oidc provider id"
  nullable    = false
}
