
variable "resource_prefix" {
  default = ""
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
}

variable "root_ca_crt" {
  default = ""
  # validation {
  #   condition     = length(var.root_ca_crt) < 1
  #   error_message = "The root_ca_crt is required field."
  # }
}

variable "root_ca_key" {
  default = ""
  # validation {
  #   condition     = length(var.root_ca_key) < 1
  #   error_message = "The root_ca_key is required field."
  # }
}

variable "root_ca_acm_arn" {
  default = ""
}
variable "vpc_cidr_block" {
  default = ""
}

variable "a_subnet_id"{
  default = ""
}

variable "vpc_id" {
  default = ""
} 