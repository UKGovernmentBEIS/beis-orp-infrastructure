module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 7.0"

  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-2017-01"

  name = "beis-alb"

  load_balancer_type               = "application"
  enable_cross_zone_load_balancing = true

  vpc_id = module.vpc.vpc_id
  subnets = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1],
    module.vpc.public_subnets[2]
  ]
  security_groups = [aws_security_group.alb.id]

  target_groups = [
    {
      name             = "beis-alb-tg"
      backend_protocol = "HTTP"
      backend_port     = 3000
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = aws_acm_certificate_validation.app_validation.certificate_arn
      action_type        = "forward"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "forward"
      #      redirect = {
      #        port        = "3000"
      #        protocol    = "HTTP"
      #        status_code = "HTTP_301"
      #      }
      target_group_index = 0

    }
  ]
}
