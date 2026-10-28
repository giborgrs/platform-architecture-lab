terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }

  # Supplied at init time: terraform init -backend-config=backend.hcl
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.tags
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    layer       = "10-network"
    managed_by  = "terraform"
  }
}

module "network" {
  source = "../../../../../modules/network/aws"

  name_prefix        = local.name_prefix
  cidr_block         = var.cidr_block
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  tags               = local.tags
}

# Consumed by the next layer (20-cluster) via terraform_remote_state.
output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "data_subnet_ids" {
  value = module.network.data_subnet_ids
}
