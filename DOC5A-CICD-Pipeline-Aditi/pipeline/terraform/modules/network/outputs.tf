output "vpc_id" {
  description = "ID of the NovaPay VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs, one per configured availability zone."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, one per configured availability zone."
  value       = aws_subnet.private[*].id
}
