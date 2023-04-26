output "public_subnet_ids" {
  value       = var.existing != null ? [for k, v in data.aws_subnet.public : v.id] : module.subnets.public_subnet_ids
  description = "Public subnet IDs"
}

output "public_subnet_cidrs" {
  value       = var.existing != null ? [for k, v in data.aws_subnet.public : v.cidr_block] : module.subnets.public_subnet_cidrs
  description = "Public subnet CIDRs"
}

output "private_subnet_ids" {
  value       = var.existing != null ? [for k, v in data.aws_subnet.private : v.id] : module.subnets.public_subnet_ids
  description = "Private subnet IDs"
}

output "private_subnet_cidrs" {
  value       = var.existing != null ? [for k, v in data.aws_subnet.private : v.cidr_block] : module.subnets.private_subnet_cidrs
  description = "Private subnet CIDRs"
}

output "subnets" {
  value = {
    public : {
      ids : var.existing != null ? [for k, v in data.aws_subnet.public : v.id] : module.subnets.public_subnet_ids
      cidr : var.existing != null ? [for k, v in data.aws_subnet.public : v.cidr_block] : module.subnets.public_subnet_cidrs
    }
    private : {
      ids : var.existing != null ? [for k, v in data.aws_subnet.private : v.id] : module.subnets.private_subnet_ids
      cidr : var.existing != null ? [for k, v in data.aws_subnet.private : v.cidr_block] : module.subnets.private_subnet_cidrs
    }
  }
  description = "Subnets info map"
}

output "vpc_default_network_acl_id" {
  value       = var.existing != null ? join("", data.aws_network_acls.existing[0].ids) : module.vpc.vpc_default_network_acl_id
  description = "The ID of the network ACL created by default on VPC creation"
}

output "vpc_default_security_group_id" {
  value       = var.existing != null ? join("", data.aws_security_group.existing.*.id) : module.vpc.vpc_default_security_group_id
  description = "The ID of the security group created by default on VPC creation"
}

output "vpc_id" {
  value       = var.existing != null ? data.aws_vpc.existing[0].id : module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = var.existing != null ? data.aws_vpc.existing[0].cidr_block : module.vpc.vpc_cidr_block
  description = "VPC CIDR"
}

output "vpc" {
  value = {
    id : var.existing != null ? join("", data.aws_vpc.existing.*.id) : module.vpc.vpc_id
    cidr : var.existing != null ? join("", data.aws_vpc.existing.*.cidr_block) : module.vpc.vpc_cidr_block
    subnet_type_tag_key : var.existing != null ? "" : var.subnet_type_tag_key
    # subnet_type_tag_value_format : var.subnet_type_tag_value_format
  }
  description = "VPC info map"
}

output "private_route_table_ids" {
  value       = var.existing != null ? data.aws_route_tables.private[0].ids : module.subnets.private_route_table_ids
  description = "Private subnet route table IDs"
}

output "public_route_table_ids" {
  value       = var.existing != null ? data.aws_route_tables.public[0].ids : module.subnets.public_route_table_ids
  description = "Public subnet route table IDs"
}

output "route_tables" {
  value = {
    public : {
      ids : var.existing != null ? data.aws_route_tables.public[0].ids : module.subnets.public_route_table_ids
    }
    private : {
      ids : var.existing != null ? data.aws_route_tables.private[0].ids : module.subnets.private_route_table_ids
    }
  }
  description = "Route tables info map"
}

output "nat_gateway_ids" {
  value       = var.existing != null ? data.aws_nat_gateways.existing[0].ids : module.subnets.nat_gateway_ids
  description = "NAT Gateway IDs"
}

output "nat_instance_ids" {
  value       = var.existing != null ? [for k, v in data.aws_instance.nat_instance : v.instance_id] : module.subnets.nat_instance_ids
  description = "NAT Instance IDs"
}

output "nat_gateway_public_ips" {
  value       = var.existing != null ? [for k, v in data.aws_nat_gateway.existing : v.public_ip] : module.subnets.nat_gateway_public_ips
  description = "NAT Gateway public IPs"
}

output "max_subnet_count" {
  value       = var.existing != null ? length(toset(concat([for k, v in data.aws_subnet.public : v.availability_zone], [for k, v in data.aws_subnet.private : v.availability_zone]))) : local.max_subnet_count
  description = "Maximum allowed number of subnets before all subnet CIDRs need to be recomputed"
}

output "nat_eip_protections" {
  description = "List of AWS Shield Advanced Protections for NAT Elastic IPs."
  value       = var.existing != null ? null : aws_shield_protection.nat_eip_shield_protection
}

output "interface_vpc_endpoints" {
  description = "List of Interface VPC Endpoints in this VPC."
  value       = var.existing != null ? [for k, v in data.aws_vpc_endpoint.interface_endpoint : v] : try(module.vpc_endpoints[0].interface_vpc_endpoints, [])
}

output "gateway_vpc_endpoints" {
  description = "List of Interface VPC Endpoints in this VPC."
  value       = var.existing != null ? [for k, v in data.aws_vpc_endpoint.gateway_endpoint : v] : try(module.vpc_endpoints[0].gateway_vpc_endpoints, [])
}

output "availability_zones" {
  description = "List of Availability Zones where subnets were created"
  value       = var.existing != null ? toset(concat([for k, v in data.aws_subnet.public : v.availability_zone], [for k, v in data.aws_subnet.private : v.availability_zone])) : module.subnets.availability_zones
}

output "internet_gateway_id" {
  description = "Id of Internet Gateway attached to this VPC."
  value       = var.existing != null ? data.aws_internet_gateway.existing[0].internet_gateway_id : module.vpc.igw_id
}
