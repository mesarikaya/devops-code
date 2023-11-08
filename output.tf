output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "jenkins_ec2_public_ip" {
  description = "The Public IP address used to access jenkins related EC2 instances"
  value       = aws_instance.jenkins_instance[*].public_ip
}

output "jenkins_private_ip" {
  description = "The Private IP address used to access jenkins master EC2 instance"
  value       = aws_instance.jenkins_instance[0].private_ip
}
output "jenkins_slave_private_ip" {
  description = "The Private IP address used to access jenkins slave EC2 instance"
  value       = aws_instance.jenkins_instance[1].private_ip
}

output "ansible_ec2_public_ip" {
  description = "The Public IP address used to access ansible EC2 instance"
  value       = aws_instance.ansible_control_plane.public_ip
}

output "ansible_control_plane_private_ip" {
  value = aws_instance.ansible_control_plane.private_ip
}