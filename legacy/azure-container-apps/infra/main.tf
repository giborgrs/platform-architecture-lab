locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = merge(var.tags, {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../modules/network"

  name_prefix                   = local.name_prefix
  location                      = azurerm_resource_group.this.location
  resource_group_name           = azurerm_resource_group.this.name
  address_space                 = var.vnet_address_space
  container_apps_subnet_cidr    = var.container_apps_subnet_cidr
  private_endpoints_subnet_cidr = var.private_endpoints_subnet_cidr
  tags                          = local.tags
}

module "app" {
  source = "../modules/container_app"

  name_prefix           = local.name_prefix
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  subnet_id             = module.network.container_apps_subnet_id
  internal_only         = var.internal_only
  app_name              = var.app_name
  image                 = var.app_image
  cpu                   = var.app_cpu
  memory                = var.app_memory
  min_replicas          = var.app_min_replicas
  max_replicas          = var.app_max_replicas
  target_port           = var.app_target_port
  environment_variables = var.app_environment_variables
  log_retention_days    = var.log_retention_days
  tags                  = local.tags
}
