variable "aws_region" {
  description = "AWS region for the dev foundation."
  type        = string
  default     = "ap-south-1"
}

variable "availability_zones" {
  description = "Two availability zones available to the selected account and region."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "Select at least two availability zones."
  }
}

variable "administrator_role_arn" {
  description = "Existing IAM role allowed to administer the private EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Supported EKS Kubernetes minor version. Update after checking AWS regional availability."
  type        = string
  default     = "1.37"
}
