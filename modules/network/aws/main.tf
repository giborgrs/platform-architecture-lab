data "aws_availability_zones" "available" {
  state = "available"
}

# LEARNING NOTE: how the address space is carved up (default /16 -> 10.10.0.0/16)
#   public  /24 x N : load balancers + NAT gateways        (10.10.0.0/24, 10.10.1.0/24, ...)
#   private /20 x N : EKS nodes AND pods (VPC CNI gives every pod a VPC IP, so this is big)
#   data    /24 x N : databases/caches, no route to the internet at all
# One subnet of each tier per AZ, so losing an AZ never removes a tier.
locals {
  azs           = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_cidrs  = [for i in range(var.az_count) : cidrsubnet(var.cidr_block, 8, i)]
  private_cidrs = [for i in range(var.az_count) : cidrsubnet(var.cidr_block, 4, i + 1)]
  data_cidrs    = [for i in range(var.az_count) : cidrsubnet(var.cidr_block, 8, 100 + i)]

  nat_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true # required by EKS and by interface endpoints

  tags = merge(var.tags, { Name = "vpc-${var.name_prefix}" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "igw-${var.name_prefix}" })
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.public_cidrs[count.index]

  tags = merge(var.tags, {
    Name = "snet-${var.name_prefix}-public-${local.azs[count.index]}"
    tier = "public"
    # Tells the AWS load balancer controller where internet-facing LBs may be placed.
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.private_cidrs[count.index]

  tags = merge(var.tags, {
    Name = "snet-${var.name_prefix}-private-${local.azs[count.index]}"
    tier = "private"
    # Internal load balancers go here.
    "kubernetes.io/role/internal-elb" = "1"
  })
}

resource "aws_subnet" "data" {
  count             = var.az_count
  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = local.data_cidrs[count.index]

  tags = merge(var.tags, {
    Name = "snet-${var.name_prefix}-data-${local.azs[count.index]}"
    tier = "data"
  })
}

# ---------------------------------------------------------------------------
# Internet egress for private subnets (NAT). This is the main cost driver here:
# ~US$0.045/h per gateway plus data processing, so dev defaults to ONE shared NAT.
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"
  tags   = merge(var.tags, { Name = "eip-${var.name_prefix}-nat-${count.index}" })
}

resource "aws_nat_gateway" "this" {
  count         = local.nat_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id # NAT lives in a PUBLIC subnet
  tags          = merge(var.tags, { Name = "nat-${var.name_prefix}-${count.index}" })

  depends_on = [aws_internet_gateway.this]
}

# ---------------------------------------------------------------------------
# Routing
# ---------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "rt-${var.name_prefix}-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# One private route table per AZ so each AZ can use its own NAT when single_nat_gateway = false.
resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "rt-${var.name_prefix}-private-${local.azs[count.index]}" })
}

resource "aws_route" "private_nat" {
  count                  = local.nat_count > 0 ? var.az_count : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Data tier: local VPC routes only. No default route = no internet, in or out.
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.tags, { Name = "rt-${var.name_prefix}-data" })
}

resource "aws_route_table_association" "data" {
  count          = var.az_count
  subnet_id      = aws_subnet.data[count.index].id
  route_table_id = aws_route_table.data.id
}

# ---------------------------------------------------------------------------
# S3 gateway endpoint: free, and keeps S3 traffic (image layers, state, backups) off the NAT.
# ---------------------------------------------------------------------------
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = concat(
    aws_route_table.private[*].id,
    [aws_route_table.data.id],
  )

  tags = merge(var.tags, { Name = "vpce-${var.name_prefix}-s3" })
}
