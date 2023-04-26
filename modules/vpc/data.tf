locals {
  existing = var.existing != null ? true : false
}

data "aws_vpc" "existing" {
  count      = local.existing ? 1 : 0
  cidr_block = var.existing.cidr_block
  id         = var.existing.vpc_id
  tags       = var.existing.tags
}

data "aws_subnets" "public" {
  count = local.existing ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "subnet-id"
    values = var.existing.subnets.public
  }
}

data "aws_subnets" "private" {
  count = local.existing ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  filter {
    name   = "subnet-id"
    values = var.existing.subnets.private
  }
}

data "aws_subnet" "public" {
  for_each = local.existing ? toset(data.aws_subnets.public[0].ids) : toset([])
  id       = each.value
}

data "aws_subnet" "private" {
  for_each = local.existing ? toset(data.aws_subnets.private[0].ids) : toset([])
  id       = each.value
}

data "aws_network_acls" "existing" {
  count  = local.existing ? 1 : 0
  vpc_id = data.aws_vpc.existing[0].id
}

data "aws_security_group" "existing" {
  count  = local.existing && var.existing.default_sg_id != null ? 1 : 0
  vpc_id = data.aws_vpc.existing[0].id
  id     = var.existing.default_sg_id
}

data "aws_route_tables" "private" {
  count = local.existing ? 1 : 0
  filter {
    name   = "association.subnet-id"
    values = data.aws_subnets.private[0].ids
  }
}

data "aws_route_tables" "public" {
  count = local.existing ? 1 : 0
  filter {
    name   = "association.subnet-id"
    values = data.aws_subnets.public[0].ids
  }
}

data "aws_vpc_endpoint_service" "interface_endpoint_service" {
  for_each     = local.existing ? { for v in var.existing.interface_vpc_endpoints : v => v } : {}
  service      = each.key
  service_type = "Interface"
}

data "aws_vpc_endpoint_service" "gateway_endpoint_service" {
  for_each     = local.existing ? { for v in var.existing.gateway_vpc_endpoints : v => v } : {}
  service      = each.key
  service_type = "Gateway"
}

data "aws_vpc_endpoint" "interface_endpoint" {
  for_each     = local.existing ? data.aws_vpc_endpoint_service.interface_endpoint_service : {}
  vpc_id       = data.aws_vpc.existing[0].id
  service_name = each.value.service_name
  filter {
    name   = "vpc-endpoint-type"
    values = [each.value.service_type]
  }
}

data "aws_vpc_endpoint" "gateway_endpoint" {
  for_each     = local.existing ? data.aws_vpc_endpoint_service.gateway_endpoint_service : {}
  vpc_id       = data.aws_vpc.existing[0].id
  service_name = each.value.service_name
  filter {
    name   = "vpc-endpoint-type"
    values = [each.value.service_type]
  }
}

data "aws_instance" "nat_instance" {
  for_each    = local.existing ? { for v in var.existing.nat_instance_ids : v => v } : {}
  instance_id = each.key
}

data "aws_nat_gateways" "existing" {
  count  = local.existing ? 1 : 0
  vpc_id = data.aws_vpc.existing[0].id
}

data "aws_nat_gateway" "existing" {
  for_each = local.existing ? { for v in data.aws_nat_gateways.existing[0].ids : v => v } : {}
  id       = each.key
  vpc_id   = data.aws_vpc.existing[0].id
}

data "aws_internet_gateway" "existing" {
  count = local.existing ? 1 : 0
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
}
