variable "name_prefix" {
  description = "Prefix used for resource names, e.g. myapp-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into."
  type        = string
}

variable "subnet_id" {
  description = "Delegated subnet ID for the Container Apps environment."
  type        = string
}

variable "internal_only" {
  description = "If true, the environment is only reachable from inside the VNet."
  type        = bool
  default     = true
}

variable "app_name" {
  description = "Container app name (suffix)."
  type        = string
}

variable "image" {
  description = "Container image reference."
  type        = string
}

variable "cpu" {
  description = "vCPU per replica (0.25, 0.5, 0.75, 1.0, ...)."
  type        = number
  default     = 0.5
}

variable "memory" {
  description = "Memory per replica; must be 2x CPU, e.g. 1Gi for 0.5 vCPU."
  type        = string
  default     = "1Gi"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 3
}

variable "target_port" {
  description = "Port the container listens on."
  type        = number
  default     = 80
}

variable "environment_variables" {
  description = "Non-secret environment variables for the container."
  type        = map(string)
  default     = {}
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
