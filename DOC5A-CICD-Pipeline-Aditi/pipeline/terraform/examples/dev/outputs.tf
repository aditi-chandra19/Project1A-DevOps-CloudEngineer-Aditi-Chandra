output "cluster_name" {
  description = "Name of the private EKS cluster."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Private EKS API endpoint. It is reachable only from an approved VPC network path."
  value       = module.eks.cluster_endpoint
}

output "vpc_id" {
  description = "ID of the NovaPay dev VPC."
  value       = module.network.vpc_id
}
