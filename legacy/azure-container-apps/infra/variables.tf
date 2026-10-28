variable "project" {
  description = "Short project name used in resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,12}$", var.project))
    error_message = "Use 2-12 lowercase letters/digits."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "Must be one of: dev, qa, prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  type = string
}

variable "container_apps_subnet_cidr" {
  type = string
}

variable "private_endpoints_subnet_cidr" {
  type = string
}

variable "internal_only" {
  description = "Restrict the Container Apps environment to VNet-only access."
  type        = bool
  default     = true
}

variable "app_name" {
  type    = string
  default = "api"
}

variable "app_image" {
  type = string
}

variable "app_cpu" {
  type    = number
  default = 0.5
}

variable "app_memory" {
  type    = string
  default = "1Gi"
}

variable "app_min_replicas" {
  type    = number
  default = 1
}

variable "app_max_replicas" {
  type    = number
  default = 3
}

variable "app_target_port" {
  type    = number
  default = 80
}

variable "app_environment_variables" {
  description = "Non-secret environment variables for the app."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
