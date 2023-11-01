variable "kubernetes_tags" {
  description = "Tags to for Kubernetes cluster"
  type        = map(string)
}

variable "has_cluster_public_access" {
  description = "Boolean to give public or private access to kubernetes cluster"
  type = bool
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet for VPC"
  type        = list(string)
}