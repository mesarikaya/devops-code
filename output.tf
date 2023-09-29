output "ec2_public_ip" {
  description = "The Public IP address used to access EC2 instance"
  value       = aws_instance.linux_instance.public_ip
}