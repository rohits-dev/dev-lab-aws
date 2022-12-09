variable "aws_region" {
  default = "eu-west-2"
}

variable "resource_prefix" {
  default = ""
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
}

variable "github_owner" {
  type        = string
  description = "github owner"
  # validation {
  #   condition     = length(var.github_owner) < 1
  #   error_message = "The github_owner is required field."
  # }
}

variable "repository_name" {
  type        = string
  default     = ""
  description = "github repository name"
  # validation {
  #   condition     = length(var.repository_name) < 1
  #   error_message = "The repository_name is required field."
  # }
}

variable "branch" {
  type        = string
  default     = "main"
  description = "branch name"
}


variable "target_path" {
  type        = string
  default     = "./"
  description = "flux sync target path"
}

variable "eks_oidc_provider_arn" {
  type = string
  default = ""
  description = "eks oidc provider arn"
  # validation {
  #   condition     = length(var.eks_oidc_provider_arn) < 1
  #   error_message = "The eks_oidc_provider_arn is required field."
  # }
}

variable "eks_oidc_provider" {
  type = string
  default = ""
  description = "eks oidc provider id"
  # validation {
  #   condition     = length(var.eks_oidc_provider_arn) < 1
  #   error_message = "The eks_oidc_provider_arn is required field."
  # }
}

variable "route_53_zone_id" {
  nullable = false
}

variable "route_53_zone_arn" {
  nullable = false
}