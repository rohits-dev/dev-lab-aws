variable "resource_prefix" {
  nullable = false
}
variable "vpc_id" {
  type        = string
  default     = null
  description = "Existing vpc-id"
}

variable "aws_region" {
  nullable = false
}
variable "private_subnets_name_filter" {
  type        = list(string)
  default     = ["*private*", "*Private*", "*PRIVATE*"]
  description = "Name filter to find all private subnets"
}
variable "public_subnets_name_filter" {
  type        = list(string)
  default     = ["*public*", "*Public*", "*PUBLIC*"]
  description = "Name filter to find all private subnets"
}

variable "cluster_name" {
  default     = null
  description = "name of eks cluster"
}
