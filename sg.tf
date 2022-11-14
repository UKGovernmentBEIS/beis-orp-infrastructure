resource "aws_security_group" "ecs" {
  name        = "beis-orp-ecs"
  description = "Security Group for BEIS ORP ECS"
  vpc_id      = aws_vpc.beis_orp.id
}

resource "aws_security_group" "alb" {
  name        = "beis-orp-alb"
  description = "Security Group for BEIS ORP ECS ALB"
  vpc_id      = aws_vpc.beis_orp.id
}

#http inbound redirects to https, this just allows the traffic.
resource "aws_security_group_rule" "alb_ingress_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#resource "aws_security_group_rule" "alb_ingress_https" {
#  from_port         = 443
#  protocol          = "tcp"
#  security_group_id = aws_security_group.alb.id
#  to_port           = 443
#  type              = "ingress"
#  cidr_blocks       = ["0.0.0.0/0"]
#}

resource "aws_security_group_rule" "alb_egress_all" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
