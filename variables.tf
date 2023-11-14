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
  default = [8080, 8000, 80, 443]
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
  default     = "10.1.0.0/16"
  description = "CIDR block for VPC"
  type        = string
}

variable "cluster_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_private_subnets" {
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
  description = "Private subnet for VPC"
  type        = list(string)
}

variable "vpc_public_subnets" {
  default     = ["10.1.101.0/24", "10.1.102.0/24"]
  description = "Public subnet for VPC"
  type        = list(string)
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "vpc_single_nat_gateway" {
  description = "Single NAT gateway for VPC"
  type        = bool
  default     = true
}

variable "vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC"
  type        = bool
  default     = true
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

variable "artifactory_name" {
  description = "Code Artifactory name"
  type        = string
  default     = "devops-code-artifactory"
}

variable "domain_name" {
  description = "Code Artifactory Domain"
  type        = string
  default     = "devops-code-artifactory-domain"
}

variable "codeartifact_repository_name" {
  description = "Code Artifactory Name"
  type        = string
  default     = "devops-code-artifactory-name"
}