variable "kubernetes_tags" {
  description = "Tags to for Kubernetes cluster"
  type        = map(string)
}

variable "cluster_endpoint_public_access" {
  description = "Boolean to give public or private access to kubernetes cluster"
  type = bool
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet for EKS"
  type        = list(string)
}

variable "iam_role_arn" {
  description = "Worker instance arne"
  type = string
}