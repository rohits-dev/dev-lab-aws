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

variable "target_path_vault_issuer" {
  type        = string
  default     = "./"
  description = "vault issuer sync target path"
}