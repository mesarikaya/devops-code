/*module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.0"

  cluster_name    = var.kubernetes_tags.cluster_name

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.subnet_ids
  cluster_endpoint_public_access = var.cluster_endpoint_public_access
  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      create_iam_role = false
      iam_role_arn = var.iam_role_arn
      instance_types = ["t3.small"]

      capacity_type  = "SPOT"

      min_size     = 1
      max_size     = 3
      desired_size = 1
    }
  }
  
}

# https://aws.amazon.com/blogs/containers/amazon-ebs-csi-driver-is-now-generally-available-in-amazon-eks-add-ons/ 
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.24.1-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "Eks:Addon" = "ebs-csi"
    "Terraform" = "true"
  }
}*/

###############################################################################################################
resource "aws_eks_cluster" "eks_cluster" {
  name =  var.kubernetes_tags.cluster_name
  role_arn = var.cluster_master_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
  
  depends_on = [var.eks_cluster_policy, var.eks_service_policy, var.eks_vpc_resource_controller]
}
#################################################################################################################

resource "aws_eks_node_group" "eks_backend" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = var.cluster_node_role_arn
  subnet_ids = var.subnet_ids
  capacity_type = "SPOT"
  disk_size = "20"
  instance_types = ["t3.small"]
  remote_access {
    ec2_ssh_key = var.ec2_ssh_key
    source_security_group_ids = var.ec2_ssh_security_group_ids
  } 
  
  labels =  tomap(var.kubernetes_tags)
  
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  tags = {name = "${var.environment}-cluster-node"}

  depends_on = [var.eks_worker_node_policy, var.eks_cni_policy, var.eks_container_registry_read_only]
}
