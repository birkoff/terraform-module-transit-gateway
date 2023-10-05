resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support                                     = try(var.dns_support, true) ? "enable" : "disable"
  ipv6_support                                    = try(var.ipv6_support, false) ? "enable" : "disable"
  appliance_mode_support                          = try(var.appliance_mode_support, false) ? "enable" : "disable"
  transit_gateway_default_route_table_association = try(var.transit_gateway_default_route_table_association, true)
  transit_gateway_default_route_table_propagation = try(var.transit_gateway_default_route_table_propagation, true)

  tags = merge(
    var.tags,
    { Name = var.name },
  )
}

data "aws_ec2_transit_gateway_route_table" "this" {
  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = ["${var.transit_gateway_id}"]
  }
}

resource "aws_ec2_transit_gateway_route" "destination" {
  for_each                       = toset(var.tgw_routes)
  destination_cidr_block         = each.value
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.this.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
}

resource "aws_ec2_transit_gateway_route" "blackhole" {
  count                          = var.tgw_blackhole != null ? 1 : 0
  destination_cidr_block         = var.tgw_blackhole
  blackhole                      = true
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.this.id
}

resource "aws_route" "this" {
  for_each               = toset(var.route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = var.vpc_tg_route_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}
