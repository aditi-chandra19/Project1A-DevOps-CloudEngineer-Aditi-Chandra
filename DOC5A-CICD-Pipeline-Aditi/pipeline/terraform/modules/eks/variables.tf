variable "name" {
  description = "Name for the EKS cluster and managed node group."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes minor version supported by EKS in the selected region."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs across at least two availability zones."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "The cluster requires private subnets in at least two availability zones."
  }
}

variable "administrator_role_arn" {
  description = "Existing IAM role granted cluster-admin access for controlled operations."
  type        = string

  validation {
    condition     = can(regex("^arn:[^:]+:iam::[0-9]{12}:role/.+", var.administrator_role_arn))
    error_message = "Provide the ARN of an existing IAM role; do not use a user or wildcard principal."
  }
}

variable "instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Initial number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4
}

variable "tags" {
  description = "Tags applied to cluster resources."
  type        = map(string)
  default     = {}
}
