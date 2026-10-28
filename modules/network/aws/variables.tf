variable "name_prefix" {
  description = "Prefix for resource names, e.g. txn-dev."
  type        = string
}

variable "cidr_block" {
  description = "VPC CIDR. Must be a /16 so the subnet math in main.tf holds. Keep it unique across clouds/environments if you ever want to peer them."
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0)) && endswith(var.cidr_block, "/16")
    error_message = "cidr_block must be a valid /16 CIDR, e.g. 10.10.0.0/16."
  }
}

variable "az_count" {
  description = "Number of availability zones to span (2 or 3). EKS needs at least 2."
  type        = number
  default     = 3

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "enable_nat_gateway" {
  description = "Create NAT gateway(s) so private subnets can reach the internet."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "One shared NAT (cheap, but an AZ outage loses egress for all) vs one per AZ (resilient, N x cost)."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
