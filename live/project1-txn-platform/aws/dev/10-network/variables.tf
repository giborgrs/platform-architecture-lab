variable "project" {
  type    = string
  default = "txn"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type = string
}

variable "az_count" {
  type    = number
  default = 3
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}
