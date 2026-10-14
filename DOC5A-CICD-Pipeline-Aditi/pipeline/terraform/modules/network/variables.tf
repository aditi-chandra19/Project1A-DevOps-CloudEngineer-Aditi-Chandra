variable "name" {
  description = "Prefix used for network resources and Kubernetes subnet discovery tags."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Two or more availability zones in the selected AWS region."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways. Use one per availability zone for production."
  type        = number

  validation {
    condition     = var.nat_gateway_count >= 1 && var.nat_gateway_count <= length(var.availability_zones)
    error_message = "NAT gateway count must be between one and the number of availability zones."
  }
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
