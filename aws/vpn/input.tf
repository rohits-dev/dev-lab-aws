
variable "resource_prefix" {
  nullable = false
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
}

variable "root_ca_crt" {
  nullable = false
  # validation {
  #   condition     = length(var.root_ca_crt) < 1
  #   error_message = "The root_ca_crt is required field."
  # }
}

variable "root_ca_key" {
  nullable = false
  # validation {
  #   condition     = length(var.root_ca_key) < 1
  #   error_message = "The root_ca_key is required field."
  # }
}

variable "root_ca_acm_arn" {
  nullable = false
}
variable "vpc_cidr_block" {
  nullable = false
}

variable "a_subnet_id" {
  nullable = false
}

variable "vpc_id" {
  nullable = false
}
