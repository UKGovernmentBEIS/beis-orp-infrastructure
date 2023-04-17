resource "aws_cloudwatch_log_group" "beis_orp" {
  name              = "/aws/ecs/beis_orp"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "monthly" {
  name = "monthly"

  schedule_expression = "cron(0 0 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.monthly.name
  arn = module.typedb_backup.lambda_function_arn
}
