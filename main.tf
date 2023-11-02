# Define a local block to compute the tags
locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Project     = "devops-code-project"
  }
  kubernetes_tags = {
    cluster_name = "devops-kubernetes-${var.environment}"
  }
  security_group_tags = {
    name = "security_group-${var.environment}"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

/* data "aws_secretsmanager_secret_version" "ec2_private_key" {
  secret_id = "dev/ssh_private_key" # Replace with the correct secret name
  }

locals {
  private_key = data.aws_secretsmanager_secret_version.ec2_private_key.secret_string
}
 */


module "vpc" {
  source                   = "./modules/vpc"
  vpc_name                 = var.vpc_name
  vpc_cidr                 = var.vpc_cidr
  vpc_azs                  = data.aws_availability_zones.available.names
  vpc_private_subnets      = var.vpc_private_subnets
  vpc_public_subnets       = var.vpc_public_subnets
  vpc_enable_nat_gateway   = var.vpc_enable_nat_gateway
  vpc_single_nat_gateway   = var.vpc_single_nat_gateway
  vpc_enable_dns_hostnames = var.vpc_enable_dns_hostnames
  vpc_common_tags          = local.common_tags
  vpc_tags                 = var.vpc_tags
  vpc_igw_tags             = var.vpc_igw_tags
}

# Create an AMI data for latest linux image from amazon
data "aws_ami" "latest_amazon_linux_x86" {
  most_recent = true
  filter {
    name   = "image-id"
    values = ["ami-05ccf7ebc9a8216aa"]
  }
  /* filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-lunar-23.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  } */

  owners = ["amazon"]
}

resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "ec2_key_pair"
  public_key = file(var.ec2_public_key)
}

module "ssh_security" {
  source              = "./modules/security_groups"
  security_group_name = "${local.security_group_tags.name}-ssh"
  vpc_id              = module.vpc.vpc_id
  allowed_ports       = var.allowed_ssh_ports
  security_group_tags = merge(local.common_tags, local.security_group_tags)
}

module "http_security" {
  source              = "./modules/security_groups"
  security_group_name = "${local.security_group_tags.name}-tcp"
  vpc_id              = module.vpc.vpc_id
  allowed_ports       = var.allowed_http_ports
  security_group_tags = merge(local.common_tags, local.security_group_tags)
}

# Create iam role to jenkins instance to be able to do actions on ec2 instances
module "iam_jenkins_role" {
  source = "./modules/iam"
}

# Create Jenkins master and slave instances
resource "aws_instance" "jenkins_instance" {
  count         = var.jenkins_ec2_instance_count
  ami           = data.aws_ami.latest_amazon_linux_x86.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    module.ssh_security.security_group_id,
    module.http_security.security_group_id
  ]
  subnet_id            = module.vpc.public_subnets[0]
  key_name             = aws_key_pair.ec2_key_pair.key_name
  iam_instance_profile = module.iam_jenkins_role.iam_jenkins_instance_profile_name

  tags = merge(local.common_tags, {
    Name = "${var.jenkins_instance_names[count.index]}"
  })
}

#Create Ansible Instance
resource "aws_instance" "ansible_control_plane" {
  ami           = data.aws_ami.latest_amazon_linux_x86.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    module.ssh_security.security_group_id,
  ]
  subnet_id = module.vpc.public_subnets[0]
  key_name  = aws_key_pair.ec2_key_pair.key_name

  tags = merge(local.common_tags, {
    Name = "ansible"
  })

  depends_on = [
    aws_instance.jenkins_instance
  ]

  user_data                   = file("scripts/ansible_setup.sh")
  user_data_replace_on_change = true
}

#Transfer private key to allow ansible control the nodes"
resource "null_resource" "transfer_private_key" {
  triggers = {
    ansible_instance_created = "${aws_instance.ansible_control_plane.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  provisioner "file" {
    source      = "${path.module}/.private/ec2_key_pair"
    destination = "/tmp/ec2_key_pair.pem"
  }

  # Move private key
  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/ec2_key_pair.pem /opt/ec2_key_pair.pem",
      "sudo chown root:root /opt/ec2_key_pair.pem",
      "sudo chmod 400 /opt/ec2_key_pair.pem"
    ]
  }

  depends_on = [aws_instance.ansible_control_plane, aws_instance.jenkins_instance]
}

# Generate host file to register the managed nodes"
resource "null_resource" "generate_hosts_file" {

  triggers = {
    ansible_instance_created        = "${aws_instance.ansible_control_plane.id}"
    jenkins_instance_master_created = "${aws_instance.jenkins_instance[0].id}"
    jenkins_instance_slave_created  = "${aws_instance.jenkins_instance[1].id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  provisioner "local-exec" {
    command = "bash scripts/prepare_ansible_instance.sh"
    environment = {
      ANSIBLE_IP       = aws_instance.ansible_control_plane.public_ip
      JENKINS_IP       = aws_instance.jenkins_instance[0].private_ip
      JENKINS_SLAVE_IP = aws_instance.jenkins_instance[1].private_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/hosts"
    destination = "/tmp/hosts"
  }

  # Install ansible
  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/hosts /opt/hosts",
      "sudo chown root:root /opt/hosts"
    ]
  }

  # "sudo chmod 400 /opt/ec2_key_pair.pem"
  depends_on = [aws_instance.ansible_control_plane, aws_instance.jenkins_instance[0], aws_instance.jenkins_instance[1]]
}


# Transfer playbooks 
resource "null_resource" "transfer_jenkins_master_playbook" {
  triggers = {
    jenkins_instance_master_created = "${aws_instance.jenkins_instance[0].id}"
    jenkins_master_playbook         = sha256(file("${path.module}/ansible/playbooks/jenkins-master-setup.yml"))
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  # Transfer jenkins playbook
  provisioner "file" {
    source      = "${path.module}/ansible/playbooks/jenkins-master-setup.yml"
    destination = "/tmp/jenkins-master-setup.yml"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/jenkins-master-setup.yml /opt/jenkins-master-setup.yml",
      "sudo chown root:root /opt/jenkins-master-setup.yml",
    ]
  }

  depends_on = [aws_instance.ansible_control_plane]
}

resource "null_resource" "transfer_jenkins_slave_playbook" {
  triggers = {
    jenkins_instance_slave_created = "${aws_instance.jenkins_instance[1].id}"
    jenkins_slave_playbook         = sha256(file("${path.module}/ansible/playbooks/jenkins-slave-setup.yml"))
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  # Transfer jenkins playbook
  provisioner "file" {
    source      = "${path.module}/ansible/playbooks/jenkins-slave-setup.yml"
    destination = "/tmp/jenkins-slave-setup.yml"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/jenkins-slave-setup.yml /opt/jenkins-slave-setup.yml",
      "sudo chown root:root /opt/jenkins-slave-setup.yml",
    ]
  }

  depends_on = [aws_instance.ansible_control_plane]
}

resource "null_resource" "install_jenkins" {

  /*   triggers = {
    always_run = "${timestamp()}"
  } */

  triggers = {
    jenkins_instance_master_created = "${aws_instance.jenkins_instance[0].id}"
    jenkins_instance_slave_created  = "${aws_instance.jenkins_instance[1].id}"
    install_jenkins_created         = "${null_resource.transfer_jenkins_master_playbook.id}"
    install_slave_jenkins_created   = "${null_resource.transfer_jenkins_slave_playbook.id}"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  #install jenkins
  provisioner "remote-exec" {

    inline = [
      "while [ ! -x $(command -v ansible-playbook) ]; do",
      "  echo 'Waiting for Ansible to become available...'",
      "  sleep 5",
      "done",
      "sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/hosts /opt/jenkins-master-setup.yml",
      "echo 'Jenkins master installation Complete'",
      "sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/hosts /opt/jenkins-slave-setup.yml",
      "echo 'Jenkins slave installation Complete'"
    ]
  }

  depends_on = [aws_instance.ansible_control_plane,
    aws_instance.jenkins_instance[0],
    aws_instance.jenkins_instance[1],
    null_resource.generate_hosts_file,
    null_resource.transfer_jenkins_master_playbook,
  null_resource.transfer_jenkins_slave_playbook]
}

/* 
# Setup Kubernetes Cluster
module "kubernetes_cluster" {
  source          = "./modules/eks"
  kubernetes_tags = security_group_tags =  merge(local.common_tags, local.kubernetes_tags)

  vpc_id                    = module.vpc.vpc_id
  private_subnets           = module.vpc.private_subnets
  has_cluster_public_access = true
}

resource "null_resource" "transfer_jenkins_slave_install_clis_playbook_and_run" {
  triggers = {
    jenkins_instance_slave_created = "${aws_instance.jenkins_instance[1].id}"
    jenkins_slave_install_playbook = sha256(file("${path.module}/ansible/playbooks/jenkins-slave-install-clis.yml"))
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(".private/ec2_key_pair")
    host        = aws_instance.ansible_control_plane.public_ip
  }

  # Transfer jenkins playbook
  provisioner "file" {
    source      = "${path.module}/ansible/playbooks/jenkins-slave-install-clis.yml"
    destination = "/tmp/jenkins-slave-install-clis.yml"
  }

  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/jenkins-slave-install-clis.yml /opt/jenkins-slave-install-clis.yml",
      "sudo chown root:root /opt/jenkins-slave-install-clis.yml",
    ]
  }

  provisioner "remote-exec" {

    inline = [
      "sudo ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /opt/hosts /opt/jenkins-slave-install-clis.yml",
      "echo 'AWS CLI and Kubectl CLI installation on Jenkins slave instance is Complete'"
    ]
  }

  depends_on = [aws_instance.ansible_control_plane, module.kubernetes_cluster]
}

 */
moved {
  from = aws_security_group.ec2_instance_ssh_sg
  to   = module.ssh_security.aws_security_group.security_group
}

moved {
  from = aws_vpc_security_group_ingress_rule.ec2_ssh_inbound
  to   = module.ssh_security.aws_vpc_security_group_ingress_rule.ingress_rule
}

moved {
  from = aws_security_group.ec2_instance_http_sg
  to   = module.http_security.aws_security_group.security_group
}

moved {
  from = aws_vpc_security_group_ingress_rule.ec2_tcp_inbound
  to   = module.http_security.aws_vpc_security_group_ingress_rule.ingress_rule
}

moved {
  from = aws_vpc_security_group_egress_rule.ec2_ssh_outbound
  to   = module.ssh_security.aws_vpc_security_group_egress_rule.eggress_rule
}

moved {
  from = aws_vpc_security_group_egress_rule.ec2_tcp_outbound
  to   = module.http_security.aws_vpc_security_group_egress_rule.eggress_rule
}
