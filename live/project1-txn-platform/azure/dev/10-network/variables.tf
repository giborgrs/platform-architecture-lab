variable "project" {
  type    = string
  default = "txn"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type = string
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}
