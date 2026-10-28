project     = "myapp"
environment = "prod"
location    = "eastus"

vnet_address_space            = "10.30.0.0/16"
container_apps_subnet_cidr    = "10.30.0.0/23"
private_endpoints_subnet_cidr = "10.30.2.0/24"

internal_only = true

app_image        = "mcr.microsoft.com/k8se/quickstart:latest"
app_cpu          = 1
app_memory       = "2Gi"
app_min_replicas = 2
app_max_replicas = 10

log_retention_days = 90
