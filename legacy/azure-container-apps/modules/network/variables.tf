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

variable "address_space" {
  description = "VNet CIDR, e.g. 10.10.0.0/16."
  type        = string
}

variable "container_apps_subnet_cidr" {
  description = "Subnet CIDR for the Container Apps environment (/27 or larger)."
  type        = string
}

variable "private_endpoints_subnet_cidr" {
  description = "Subnet CIDR for private endpoints."
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
