resource "aws_security_group" "security_group" {
  name_prefix = "aws-sg"
  description = "Security group for AWS Resources"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  count             = length(var.allowed_ports)
  security_group_id = aws_security_group.security_group.id
  from_port         = element(var.allowed_ports, count.index)
  to_port           = element(var.allowed_ports, count.index)
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
