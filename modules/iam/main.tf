resource "aws_iam_role" "iam_jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_instance_profile" "jenkins_instance_role_profile" {
  name = "jenkins_instance_role_profile"
  role = aws_iam_role.iam_jenkins_role.name
}