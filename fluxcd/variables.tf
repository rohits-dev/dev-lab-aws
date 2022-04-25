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

variable "repository_visibility" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "target_path" {
  type        = string
  default     = ""
  description = "flux sync target path"
}