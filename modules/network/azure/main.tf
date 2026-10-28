# LEARNING NOTE: Azure vs AWS shape
#  - A VNet is regional and subnets are NOT tied to a zone; zone redundancy is set on the
#    resources placed in them (AKS node pools, NAT gateway, databases).
#  - Subnets get a default route to the internet, so "private" is expressed with NSGs and
#    (optionally) a NAT gateway for predictable egress, not by removing a route table entry.
#
# Address plan (default /16 -> 10.20.0.0/16):
#   aks  /20 : AKS nodes (and pods if you choose Azure CNI without overlay)
#   data /24 : private endpoints for PostgreSQL, Redis, Key Vault, ...
locals {
  aks_cidr  = cidrsubnet(var.address_space, 4, 1)
  data_cidr = cidrsubnet(var.address_space, 8, 100)
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_space]
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.aks_cidr]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [local.data_cidr]

  private_endpoint_network_policies = "Enabled"
}

# ---------------------------------------------------------------------------
# NSGs: the Azure equivalent of AWS security groups + NACLs, attached per subnet.
# ---------------------------------------------------------------------------
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-${var.name_prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_network_security_group" "data" {
  name                = "nsg-${var.name_prefix}-data"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Only the AKS subnet may talk to the data subnet; everything else inbound is denied.
resource "azurerm_network_security_rule" "data_allow_aks" {
  name                        = "allow-from-aks"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["5432", "6379", "443"]
  source_address_prefix       = local.aks_cidr
  destination_address_prefix  = local.data_cidr
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

resource "azurerm_network_security_rule" "data_deny_rest" {
  name                        = "deny-all-inbound"
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data.name
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# ---------------------------------------------------------------------------
# Optional NAT gateway: one stable public IP for all AKS egress (bills hourly, like AWS NAT).
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "nat" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "pip-${var.name_prefix}-nat"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  count               = var.enable_nat_gateway ? 1 : 0
  name                = "nat-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.enable_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  count          = var.enable_nat_gateway ? 1 : 0
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}
