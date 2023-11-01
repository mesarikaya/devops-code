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


variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
}

variable "vpc_igw_tags" {
  description = "Tags to apply to Internet Gateway"
  type        = map(string)
}


variable "vpc_common_tags" {
  description = "Common Tags for VPC"
  type        = map(string)
}