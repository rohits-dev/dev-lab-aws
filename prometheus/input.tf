variable "resource_prefix" {
  default = ""
  # validation {
  #   condition     = length(var.resource_prefix) < 1
  #   error_message = "The RESOURCE_PREFIX is required field."
  # }
}
