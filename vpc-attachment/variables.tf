variable "name" {
  default = ""
}
variable "description" {
  default = ""
}
variable "transit_gateway_id" {
  default = ""
}
variable "tgw_routes" {
  type = any
}
variable "tgw_blackhole" {
  type = string
}
variable "tags" {
  type = map(string)
}

variable "vpc_id" {
  default = ""
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
variable "route_table_ids" {
  type = list(string)
}
variable "vpc_tg_route_cidr_block" {
  default = ""
}