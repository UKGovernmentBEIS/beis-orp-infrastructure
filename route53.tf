data "aws_route53_zone" "beis" {
name         = "${local.environment}.open-regulation.beis.gov.uk."
private_zone = false
}

#data "aws_route53_zone" "bre-orp-alpha.io" {
#  count        = var.route53_zone_prod ? 1 : 0
#  name         = "${local.environment}.bre-orp-alpha.io."
#  private_zone = false
#}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.beis.zone_id
  name    = "app.${data.aws_route53_zone.beis.name}"
  type    = "CNAME"
  ttl     = "60"
  records = [module.alb.lb_dns_name]
}

resource "aws_acm_certificate" "app_validation" {
  domain_name       = "app.${data.aws_route53_zone.beis.name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "app_validation" {
  for_each = {
    for dvo in aws_acm_certificate.app_validation.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.beis.zone_id
}

resource "aws_acm_certificate_validation" "app_validation" {
  certificate_arn         = aws_acm_certificate.app_validation.arn
  validation_record_fqdns = [for record in aws_route53_record.app_validation : record.fqdn]
}
