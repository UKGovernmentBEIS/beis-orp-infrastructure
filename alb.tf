module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 7.0"

  name = "beis-alb"

  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true

  vpc_id  = aws_vpc.beis_orp.id
  subnets = [
    aws_subnet.subneta.id,
    aws_subnet.subnetb.id,
    aws_subnet.subnetc.id,
  ]
  security_groups = [aws_security_group.alb.id]
  target_groups = [
    {
      name             = "beis-alb-tg"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
      matcher          = "200-499"
      port             = 80
      timeout          = 60
      interval         = 90
      path             = "/"
      protocol         = "HTTP"
    }
  ]

#  https_listeners = [
#    {
#      port               = 443
#      protocol           = "HTTPS"
#      certificate_arn    = aws_acm_certificate.webserver.arn
#      action_type        = "forward"
#      target_group_index = 0
#    }
#  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "3000"
        protocol    = "HTTP"
        status_code = "HTTP_301"
      }
      target_group_index = 0

    }
  ]
}
