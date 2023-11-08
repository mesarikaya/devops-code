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
      },
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_instance_role_profile" {
  name = "jenkins_instance_role_profile"
  role = aws_iam_role.iam_jenkins_role.name
}

resource "aws_iam_policy" "s3_access_policy" {
  name        = "devops-infra-s3-manager-access-policy"
  description = "Policy for accessing AWS Secrets Manager"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  policy_arn = aws_iam_policy.s3_access_policy.arn
  role       = aws_iam_role.iam_jenkins_role.name
}

resource "aws_iam_policy" "eks_access_policy" {
  name        = "devops-infra-eks-manager-access-policy"
  description = "Policy for accessing AWS EKS"

  policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "Statement1",
          "Effect": "Allow",
          "Action": [
            "eks:ListNodegroups",
            "eks:DescribeFargateProfile",
            "eks:DescribeAddonConfiguration",
            "eks:UntagResource",
            "eks:ListTagsForResource",
            "eks:ListAddons",
            "eks:DescribeAddon",
            "eks:ListFargateProfiles",
            "eks:DescribeNodegroup",
            "eks:DescribeIdentityProviderConfig",
            "eks:AssociateEncryptionConfig",
            "eks:ListUpdates",
            "eks:DescribeUpdate",
            "eks:TagResource",
            "eks:AccessKubernetesApi",
            "eks:DescribeCluster",
            "eks:ListClusters",
            "eks:DescribeAddonVersions",
            "eks:ListIdentityProviderConfigs",
            "eks:AssociateIdentityProviderConfig"
          ],
          "Resource": "arn:aws:eks:eu-west-1:880787496735:cluster/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "eks_access_attachment" {
  policy_arn = aws_iam_policy.eks_access_policy.arn
  role       = aws_iam_role.iam_jenkins_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.iam_jenkins_role.name
}







# Create IAM setup for eks worker nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "eks_worker_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "autoscaler" {
  name   = "eks-autoscaler-policy"
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeTags",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.eks_worker_role.name
}
resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.eks_worker_role.name
}

resource "aws_iam_instance_profile" "eks_worker_role_profile" {
  depends_on = [aws_iam_role.eks_worker_role]
  name       = "eks_worker_role_profile"
  role       = aws_iam_role.eks_worker_role.name
}