output "name" {
    value = aws_iam_role.iam_jenkins_role.name
}

output "iam_jenkins_instance_profile" {
    value = aws_iam_instance_profile.jenkins_instance_role_profile
}

output "iam_jenkins_instance_profile_name" {
    value = aws_iam_instance_profile.jenkins_instance_role_profile.name
}

output "iam_eks_master_role_arn" {
    value = aws_iam_role.eks_master.arn
}

output "iam_eks_worker_role_arn" {
    value = aws_iam_role.eks_worker_role.arn
}

output "eks_cluster_policy" {
    value = aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
}

output "eks_service_policy" {
    value = aws_iam_role_policy_attachment.AmazonEKSServicePolicy
}

output "eks_vpc_resource_controller" {
    value = aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
}

output "eks_worker_node_policy" {
    value = aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
}

output "eks_cni_policy" {
    value = aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
}

output "eks_container_registry_read_only" {
    value = aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
}