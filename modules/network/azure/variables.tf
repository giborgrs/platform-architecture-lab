variable "name_prefix" {
  description = "Prefix for resource names, e.g. txn-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group to create the network in."
  type        = string
}

variable "address_space" {
  description = "VNet CIDR. Must be a /16 so the subnet math in main.tf holds. Keep it distinct from the AWS VPC CIDR."
  type        = string

  validation {
    condition     = can(cidrhost(var.address_space, 0)) && endswith(var.address_space, "/16")
    error_message = "address_space must be a valid /16 CIDR, e.g. 10.20.0.0/16."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway for AKS egress (costs money while it exists)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
