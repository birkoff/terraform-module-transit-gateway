variable "name" {
  default = ""
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "description" {
  default = ""
}
variable "enable_mutlicast_support" {
  default = ""
}
variable "enable_vpn_ecmp_support" {
  default = ""
}
variable "enable_dns_support" {
  default = ""
}
variable "enable_auto_accept_shared_attachments" {
  default = ""
}
variable "enable_default_route_table_association" {
  default = ""
}
variable "enable_default_route_table_propagation" {
  default = ""
}
variable "amazon_side_asn" {
  description = "The Autonomous System Number (ASN) for the Amazon side of the gateway. By default the TGW is created with the current default Amazon ASN."
  type        = string
  default     = null
}
variable "transit_gateway_cidr_blocks" {
  description = "One or more IPv4 or IPv6 CIDR blocks for the transit gateway. Must be a size /24 CIDR block or larger for IPv4, or a size /64 CIDR block or larger for IPv6"
  type        = list(string)
  default     = []
}
variable "timeouts" {
  description = "Create, update, and delete timeout configurations for the transit gateway"
  type        = map(string)
  default     = {}
}
variable "ram_name" {
  description = "The name of the resource share of TGW"
  type        = string
  default     = ""
}