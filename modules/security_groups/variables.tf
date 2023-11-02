variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "allowed_ports" {
  description = "ID of the VPC where to create security group"
  type    = list(number)
}

variable "security_group_tags" {
  description = "Tags to for Ssecurity Group"
  type        = map(string)
}

variable "security_group_name" {
  description = "Name for Security Group"
  type        = string
}