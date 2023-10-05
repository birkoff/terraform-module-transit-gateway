variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "dns_support" {
  default = true
}
variable "ipv6_support" {
  default = false
}
variable "appliance_mode_support" {
  default = false
}
variable "transit_gateway_default_route_table_association" {
  default = true
}
variable "transit_gateway_default_route_table_propagation" {
  default = true
}
variable "name" {
  type = string
}
variable "private_route_table_ids" {
  type    = list(string)
  default = ["value"]
}
variable "transit_gateway_id" {}

variable "destination_cidr_block" {}