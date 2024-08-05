variable "resource_prefix" {
  nullable = false
}

variable "aws_eks_access_entries" {
  description = "Access entries to grant access to EKS cluster"
  type        = any
  default     = {}

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



variable "add_eks_public_access" {
  type        = bool
  default     = false
  description = "Make the EKS cluster private"
}

variable "cluster_additional_security_group_ids" {
  type        = list(string)
  description = "SG ids which will have access from"
}

variable "arm_or_amd" {
  type        = string
  default     = "AMD"
  description = "To test with ARM instances set it to ARM"
}

variable "cluster_name" {
  default     = null
  description = "name of eks cluster"
}

variable "private_subnets" {
  description = "list of private subnets"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}
