provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "NovaPay"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
