cidr_block         = "10.10.0.0/16"
az_count           = 3
enable_nat_gateway = true
single_nat_gateway = true # dev: one shared NAT to save cost (see ADR-0006)
