output "name" {
    value = aws_iam_role.iam_jenkins_role.name
}

output "iam_jenkins_instance_profile_name" {
    value = aws_iam_instance_profile.jenkins_instance_role_profile.name
}