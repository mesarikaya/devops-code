variable "region" {
  default     = "eu-west-1"
  description = "The AWS region of provisioned resources"
}

variable "ec2_public_key" {
  type        = string
  default     = ".ssh/ec2_key_pair.pub"
  description = "ec2 key pair public key"
}