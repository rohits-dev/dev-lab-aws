

variable "resource_prefix" {
  default = ""
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
}

variable "eks_oidc_provider_arn" {
  type        = string
  default     = ""
  description = "eks oidc provider arn"
  # validation {
  #   condition     = length(var.eks_oidc_provider_arn) < 1
  #   error_message = "The eks_oidc_provider_arn is required field."
  # }
}

variable "eks_oidc_provider" {
  type        = string
  default     = ""
  description = "eks oidc provider id"
  # validation {
  #   condition     = length(var.eks_oidc_provider_arn) < 1
  #   error_message = "The eks_oidc_provider_arn is required field."
  # }
}
