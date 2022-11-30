resource "aws_cloudwatch_log_group" "beis_orp" {
  name              = "/aws/ecs/beis_orp"
  retention_in_days = 14
}
