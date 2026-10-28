output "environment_id" {
  value = azurerm_container_app_environment.this.id
}

output "app_id" {
  value = azurerm_container_app.this.id
}

output "app_fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "app_principal_id" {
  description = "Managed identity principal ID, for granting RBAC (e.g. AcrPull, Key Vault)."
  value       = azurerm_container_app.this.identity[0].principal_id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}
