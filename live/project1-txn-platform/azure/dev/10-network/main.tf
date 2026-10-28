terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9"
    }
  }

  # Supplied at init time: terraform init -backend-config=backend.hcl
  backend "azurerm" {}
}

# Auth: `az login` locally, OIDC (ARM_* env vars) in CI. Subscription comes from the
# ARM_SUBSCRIPTION_ID env var or `az account set`, never from this repo.
provider "azurerm" {
  features {}
  storage_use_azuread = true
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

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.name_prefix}-network"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../../../../modules/network/azure"

  name_prefix         = local.name_prefix
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.address_space
  enable_nat_gateway  = var.enable_nat_gateway
  tags                = local.tags
}

# Consumed by the next layer (20-cluster) via terraform_remote_state.
output "resource_group_name" {
  value = azurerm_resource_group.network.name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "aks_subnet_id" {
  value = module.network.aks_subnet_id
}

output "data_subnet_id" {
  value = module.network.data_subnet_id
}
