project     = "myapp"
environment = "dev"
location    = "eastus"

vnet_address_space            = "10.10.0.0/16"
container_apps_subnet_cidr    = "10.10.0.0/23"
private_endpoints_subnet_cidr = "10.10.2.0/24"

internal_only = true

app_image        = "mcr.microsoft.com/k8se/quickstart:latest"
app_cpu          = 0.25
app_memory       = "0.5Gi"
app_min_replicas = 0
app_max_replicas = 2

log_retention_days = 30
