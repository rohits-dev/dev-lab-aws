variable "resource_prefix" {
  default  = ""
  nullable = false
}

variable "github_owner" {
  type        = string
  description = "github owner"
  nullable    = false
  # validation {
  #   condition     = length(var.github_owner) < 1
  #   error_message = "The github_owner is required field."
  # }
}

variable "repository_name" {
  type        = string
  description = "github repository name"
  nullable    = false
  # validation {
  #   condition     = length(var.repository_name) < 1
  #   error_message = "The repository_name is required field."
  # }
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
