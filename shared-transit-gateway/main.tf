locals {
  # List of maps with key and route values
  tgw_default_route_table_tags_merged = merge(
    var.tags,
    { Name = var.name }
  )
}

################################################################################
# Transit Gateway
################################################################################

resource "aws_ec2_transit_gateway" "this" {
  description                     = coalesce(var.description, var.name)
  amazon_side_asn                 = var.amazon_side_asn
  default_route_table_association = var.enable_default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.enable_default_route_table_propagation ? "enable" : "disable"
  auto_accept_shared_attachments  = var.enable_auto_accept_shared_attachments ? "enable" : "disable"
  multicast_support               = var.enable_mutlicast_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks

  timeouts {
    create = try(var.timeouts.create, null)
    update = try(var.timeouts.update, null)
    delete = try(var.timeouts.delete, null)
  }

  tags = merge(
    var.tags,
    { Name = var.name }
  )
}

resource "aws_ec2_tag" "this" {
  for_each = { for k, v in local.tgw_default_route_table_tags_merged : k => v if var.enable_default_route_table_association }

  resource_id = aws_ec2_transit_gateway.this.association_default_route_table_id
  key         = each.key
  value       = each.value
}

################################################################################
# Resource Access Manager
################################################################################

resource "aws_ram_resource_share" "this" {
  name                      = coalesce(var.ram_name, var.name)
  allow_external_principals = false

  tags = merge(
    var.tags,
    { Name = coalesce(var.ram_name, var.name) },
  )
}

resource "aws_ram_resource_association" "this" {
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this.id
}

data "aws_organizations_organization" "this" {}

resource "aws_ram_principal_association" "this" {
  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}


################################################################################
# Flow Logs
################################################################################
resource "aws_flow_log" "this" {
  iam_role_arn             = aws_iam_role.this.arn
  log_destination          = aws_cloudwatch_log_group.this.arn
  traffic_type             = "ALL"
  max_aggregation_interval = 60
  transit_gateway_id       = aws_ec2_transit_gateway.this.id
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/${var.name}-transit-gateway/vpc-attachments/"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-transit-gateway-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-transit-gateway-flow-logs"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}
