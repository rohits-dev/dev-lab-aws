variable "resource_prefix" {
  default = ""
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
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
