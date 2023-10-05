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

resource "aws_route" "applications_to_egress_tg" {
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.this]
  for_each               = toset(var.private_route_table_ids)
  route_table_id         = each.key
  destination_cidr_block = var.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}