project     = "myapp"
environment = "qa"
location    = "eastus"

vnet_address_space            = "10.20.0.0/16"
container_apps_subnet_cidr    = "10.20.0.0/23"
private_endpoints_subnet_cidr = "10.20.2.0/24"

internal_only = true

app_image        = "mcr.microsoft.com/k8se/quickstart:latest"
app_cpu          = 0.5
app_memory       = "1Gi"
app_min_replicas = 1
app_max_replicas = 3

log_retention_days = 30
