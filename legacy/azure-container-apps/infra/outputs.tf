output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "container_app_fqdn" {
  value = module.app.app_fqdn
}

output "container_app_principal_id" {
  value = module.app.app_principal_id
}
