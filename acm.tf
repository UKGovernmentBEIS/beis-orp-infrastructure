#resource "aws_acm_certificate" "webserver" {
#  domain_name       = "${local.domain_prefix}.${local.domain_name}"
#  validation_method = "DNS"
#}
#
#resource "aws_acm_certificate_validation" "webserver" {
#  certificate_arn         = aws_acm_certificate.webserver.arn
#  validation_record_fqdns = [for record in aws_route53_record.webserver : record.fqdn]
#}
#
#resource "aws_route53_record" "webserver" {
#  for_each = {
#  for dvo in aws_acm_certificate.webserver.domain_validation_options : dvo.domain_name => {
#    name   = dvo.resource_record_name
#    record = dvo.resource_record_value
#    type   = dvo.resource_record_type
#  }
#  }
#
#  allow_overwrite = true
#  name            = each.value.name
#  records         = [each.value.record]
#  ttl             = 60
#  type            = each.value.type
#  zone_id         = data.aws_route53_zone.public.zone_id #data.terraform_remote_state.dns.outputs.route53_public_zone_id
#}
