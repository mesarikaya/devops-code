variable "vpc_azs" {
  description = "A list of availability zones."
  type        = list(string)
}

variable "vpc_name" {
  description = "Separate VPC for devops pipeline"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_private_subnets" {
  description = "Private subnet for VPC"
  type        = list(string)
}

variable "public_subnet_tags" {
  description = "Public subnet tags for VPC"
  type = map(string)
}

variable "private_subnet_tags" {
  description = "Private subnet tags for VPC"
  type = map(string)
}

variable "vpc_public_subnets" {
  description = "Public subnet for VPC"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
}

variable "vpc_single_nat_gateway" {
  description = "Single NAT gateway for VPC"
  type        = bool
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
}

variable "vpc_common_tags" {
  description = "Common Tags for VPC"
  type        = map(string)
}