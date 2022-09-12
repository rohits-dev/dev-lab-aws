variable "resource_prefix" {
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
