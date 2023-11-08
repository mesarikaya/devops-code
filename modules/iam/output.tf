output "name" {
    value = aws_iam_role.iam_jenkins_role.name
}

output "iam_jenkins_instance_profile" {
    value = aws_iam_instance_profile.jenkins_instance_role_profile
}

output "iam_jenkins_instance_profile_name" {
    value = aws_iam_instance_profile.jenkins_instance_role_profile.name
}

output "iam_eks_worker_role_arn" {
    value = aws_iam_role.eks_worker_role.arn
}