variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "allowed_ports" {
  description = "ID of the VPC where to create security group"
  type    = list(number)
}