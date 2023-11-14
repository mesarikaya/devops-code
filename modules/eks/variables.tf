variable "kubernetes_tags" {
  description = "Tags to for Kubernetes cluster"
  type        = map(string)
}

/* variable "cluster_endpoint_public_access" {
  description = "Boolean to give public or private access to kubernetes cluster"
  type = bool
} */

/* variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
} */

variable "cluster_master_role_arn" {
  description = "Cluster master node role ARN"
  type = string
}

variable "subnet_ids" {
  description = "Subnet for EKS"
  type        = list(string)
}

variable "cluster_node_role_arn" {
  description = "Worker instance arne"
  type = string
}

/* variable "cluster_service_ipv4_cidr" {
  description = "CIDR block for Cluster"
  type        = string
} */

variable "node_group_name" {
  description = "Name of node group"
  type = string
}

variable "ec2_ssh_key" {
  description = "EC2 ssh key name"
  type = string
}

variable "ec2_ssh_security_group_ids" {
  description = "EC2 ssh security group"
  type = list(string)
}



variable "environment"{
  description = "Environment"
  type = string
}
variable "eks_cluster_policy" {
  description = "eks cluster policy"
  type = any
}

variable "eks_service_policy" {
  description = "eks service policy"
  type = any
}

variable "eks_vpc_resource_controller" {
  description = "eks vpc resource controller"
  type = any
}

variable "eks_worker_node_policy" {
  description = "eks worker node policy"
  type = any
}

variable "eks_cni_policy" {
  description = "eks cni policy"
  type = any
}

variable "eks_container_registry_read_only" {
  description = "eks container registry read only"
  type = any
}

