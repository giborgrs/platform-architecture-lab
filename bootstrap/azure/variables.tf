variable "location" {
  description = "Azure region for the state storage account."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group holding the Terraform state storage account."
  type        = string
  default     = "rg-terraform-state"
}

variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 lowercase letters and digits)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Must be 3-24 lowercase letters and digits."
  }
}

variable "container_name" {
  description = "Blob container for state files."
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    managed_by = "terraform"
    purpose    = "terraform-state"
  }
}
