locals {
  name = "novapay-dev"
}

module "network" {
  source = "../../modules/network"

  name               = local.name
  vpc_cidr           = "10.20.0.0/16"
  availability_zones = var.availability_zones
  nat_gateway_count  = 1
  tags = {
    Environment = "dev"
    Project     = "NovaPay"
  }
}

module "eks" {
  source = "../../modules/eks"

  name                   = local.name
  kubernetes_version     = var.kubernetes_version
  private_subnet_ids     = module.network.private_subnet_ids
  administrator_role_arn = var.administrator_role_arn
  node_min_size         = 2
  node_desired_size     = 2
  node_max_size         = 4
  tags = {
    Environment = "dev"
    Project     = "NovaPay"
  }
}
