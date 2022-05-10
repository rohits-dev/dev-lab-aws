variable "AWS_REGION" {
  default = "eu-west-2"
}

variable "RESOURCE_PREFIX" {
  default = ""
}


#### GITHUB ######

variable "GITHUB_TOKEN" {
  type        = string
  description = "github token"
  # validation {
  #   condition     = length(var.GITHUB_TOKEN) < 1
  #   error_message = "The GITHUB_TOKEN is required field."
  # }
}
variable "GITHUB_OWNER" {
  type        = string
  description = "github owner"
  # validation {
  #   condition     = length(var.GITHUB_OWNER) < 1
  #   error_message = "The GITHUB_OWNER is required field."
  # }
}


variable "REPOSITORY_NAME" {
  type        = string
  default     = "dev-lab-aws"
  description = "github repository name"
  # validation {
  #   condition     = length(var.REPOSITORY_NAME) < 1
  #   error_message = "The REPOSITORY_NAME is required field."
  # }
}

variable "REPOSITORY_VISIBILITY" {
  type        = string
  default     = "private"
  description = "How visible is the github repo"
}

variable "BRANCH" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "TARGET_PATH" {
  type        = string
  default     = "cluster-resources/operators/"
  description = "flux sync target path"
}

variable "ADD_FLUXCD" {
  type        = bool
  default     = false
  description = "Should add fluxcd to new EKS?"
}
