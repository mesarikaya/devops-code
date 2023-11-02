variable "region" {
  default     = "eu-west-1"
  description = "The AWS region of provisioned resources"
}

variable "environment" {
  default     = "dev"
  description = "Environment to develop and deploy"
}

# Define a list of ports you want to allow
variable "allowed_http_ports" {
  type    = list(number)
  default = [8080, 8000]
}

variable "allowed_ssh_ports" {
  type    = list(number)
  default = [22]
}

variable "vpc_name" {
  default     = "devops-vpc"
  description = "Separate VPC for devops pipeline"
  type        = string
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_private_subnets" {
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "Private subnet for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "Public subnet for VPC"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = false
}

variable "vpc_single_nat_gateway" {
  description = "Single NAT gateway for VPC"
  type        = bool
  default     = false
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
  default     = true
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Name = "devops-vpc"
  }
}

variable "vpc_igw_tags" {
  description = "Tags to apply to Internet Gateway"
  type        = map(string)
  default = {
    Name = "devops-igw"
  }
}

variable "ec2_public_key" {
  type        = string
  default     = ".ssh/ec2_key_pair.pub"
  description = "ec2 key pair public key"
}

variable "jenkins_ec2_instance_count" {
  default     = 2
  description = "Jenkins related EC2 instance count"
  type        = number
}

variable "jenkins_instance_names" {
  default = ["jenkins-master", "jenkins-slave"]
}

variable "JENKINS_USERNAME" {
  description = "Jenkins username"
  sensitive   = true
}

variable "JENKINS_PASSWORD" {
  description = "Jenkins password"
  sensitive   = true
}