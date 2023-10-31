output "security_group_id" {
  description = "The security group ID passed from this module"
  value       = aws_security_group.security_group.id
}