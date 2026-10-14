# Terraform infrastructure

This Terraform example creates an AWS foundation for a NovaPay demo: a VPC with public and private subnets, an encrypted private Amazon EKS cluster, and a managed node group. It contains no credentials and has not been applied to an AWS account.

## Layout

- `modules/network` creates a VPC, two or more public/private subnet pairs, routing, and NAT gateways.
- `modules/eks` creates a private EKS control plane, a managed node group, encrypted Kubernetes secrets and node disks, and a named administrative access role.
- `examples/dev` wires the modules together for `ap-south-1` and two availability zones.

## Review before use

Creating these resources can incur AWS charges. The example is unapplied. Do not run `terraform apply` until an account owner reviews the plan, budget, IAM access, network CIDRs, and the current AWS and Kubernetes support matrix. The dev example uses one NAT gateway to keep the example smaller; use one NAT gateway per availability zone for a resilient production network.

The EKS API endpoint is private. Access it only from an approved network path inside the VPC. `examples/dev/terraform.tfvars.example` contains an intentionally invalid example account ID; replace it with an IAM role ARN that exists in the approved account before planning. The example selects Kubernetes 1.37; verify current support and regional availability before use.

## Validate without applying

With Terraform and AWS credentials already configured, from `examples/dev`:

```powershell
terraform fmt -check -recursive ..\..
terraform init -backend=false
terraform validate
terraform plan -var-file=terraform.tfvars
```

`init` downloads the AWS provider plugin. No validation command above provisions infrastructure. Keep provider lock files for a real reviewed environment and do not commit local state or credentials.

## Operational boundary

This is infrastructure code only. It does not create a registry, install Istio or Argo CD, deploy NovaPay, configure monitoring, or prove a zero-downtime rollout. Those controls require an approved AWS account and deployment environment. A real implementation should add EKS access through a controlled access workflow, workload identity, network endpoints, backup/restore, and environment-specific policy before use.
