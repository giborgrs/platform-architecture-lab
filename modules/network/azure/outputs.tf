output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "Where AKS nodes go."
  value       = azurerm_subnet.aks.id
}

output "data_subnet_id" {
  description = "Where private endpoints for databases/caches go."
  value       = azurerm_subnet.data.id
}
