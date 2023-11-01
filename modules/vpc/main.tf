module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = slice(var.vpc_azs, 0, 1)
  private_subnets = slice(var.vpc_private_subnets, 0, 2)
  public_subnets  = slice(var.vpc_public_subnets, 0, 2)

  enable_nat_gateway      = var.vpc_enable_nat_gateway
  single_nat_gateway      = var.vpc_single_nat_gateway
  enable_dns_hostnames    = var.vpc_enable_dns_hostnames
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true

  create_igw = true

  tags     = merge(var.vpc_common_tags, var.vpc_tags)
  igw_tags = merge(var.vpc_common_tags, var.vpc_igw_tags)
}
