variable "AWS_REGION" {
  nullable = false
}

variable "RESOURCE_PREFIX" {
  nullable = false
}

variable "OWNER_EMAIL" {
  nullable = false
}

#### GITHUB ######

variable "GITHUB_TOKEN" {
  type        = string
  description = "github token"
  nullable    = false
}
variable "GITHUB_OWNER" {
  type        = string
  description = "github owner"
  nullable    = false
}


variable "REPOSITORY_NAME" {
  type        = string
  default     = "dev-lab-aws"
  description = "github repository name"
  nullable    = false
}

variable "REPOSITORY_VISIBILITY" {
  type        = string
  default     = "public"
  description = "How visible is the github repo"
}

variable "BRANCH" {
  type        = string
  default     = "main"
  description = "branch name"
}


variable "ADD_FLUXCD" {
  type        = bool
  default     = false
  description = "Should add fluxcd to new EKS?"
}

variable "AWS_AUTH_ROLES" {
  description = "List of role maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

variable "AWS_AUTH_USERS" {
  description = "List of users maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
}

# existing vpc
variable "VPC_ID" {
  type        = string
  default     = null
  description = "Existing vpc-id"
}

variable "PRIVATE_SUBNETS_NAME_FILTER" {
  type        = list(string)
  default     = ["*private*", "*Private*", "*PRIVATE*"]
  description = "Name filter to find all private subnets"
}

variable "PUBLIC_SUBNETS_NAME_FILTER" {
  type        = list(string)
  default     = ["*public*", "*Public*", "*PUBLIC*"]
  description = "Name filter to find all private subnets"
}

variable "ADD_EKS_PUBLIC_ACCESS" {
  type        = bool
  default     = false
  description = "Make the EKS cluster private"
}

variable "ARM_OR_AMD" {
  type        = string
  default     = "AMD"
  description = "To test with ARM instances set it to ARM"

}


variable "ADD_OKTA" {
  type        = bool
  default     = false
  description = "Should add OKTA apps?"
}

variable "OKTA_ORG_ID" {
  type        = string
  description = "Organization id for OKTA account or you could use name e.g. dev-69475914"

}

variable "OKTA_PRIVATE_KEY" {
  type        = string
  description = "OKTA private key"
}

variable "OKTA_PRIVATE_KEY_ID" {
  type        = string
  description = "OkTA private key id"
}
variable "OKTA_CLIENT_ID" {
  type        = string
  description = "OkTA client id"
}
