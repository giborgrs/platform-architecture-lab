terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9"
    }
  }

  # Values supplied per environment via: terraform init -backend-config=../environments/<env>/backend.hcl
  backend "azurerm" {}
}

# Auth comes from ARM_* env vars (OIDC in CI, `az login` locally).
provider "azurerm" {
  features {}
  storage_use_azuread = true
}
