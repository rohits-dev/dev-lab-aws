provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Environment = "DEV"
      Owner       = "ROHIT"
      Project     = "LAB"
      ManagedBy   = "Terraform"
    }
  }
}
