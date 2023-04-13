resource "aws_cloudwatch_event_rule" "eb_trigger" {
  name        = "eb_trigger"
  description = "Capture each Created Object"

  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail-type": ["Object Created"],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.beis-orp-upload.id}"]
    },
    "object": {
      "key": [{
        "anything-but": {
          "prefix": "unconfirmed/"
        }
      }]
    }
  }
}
EOF
}

resource "aws_cloudwatch_event_rule" "legislation_table_update_trigger" {
  name        = "legislation_table_update_trigger"
  description = "Event rule to trigger the legislation_table_update Lambda function"

  schedule_expression = "cron(0 0 ? * MON *)"
  role_arn            = aws_iam_role.legislation_update_eventbridge_role.arn
}

resource "aws_cloudwatch_event_target" "legislation_table_update_target" {
  rule      = aws_cloudwatch_event_rule.legislation_table_update_trigger.name
  arn       = module.legislation_table_update.lambda_function_arn
  target_id = "legislation_table_update_target"
  input = jsonencode(
    {
      event = "hello"
    }
  )
}

# resource "aws_lambda_permission" "event_bridge_permission" {
#   statement_id  = "AllowExecutionFromCloudWatchEvents"
#   action        = "lambda:InvokeFunction"
#   function_name = module.legislation_table_update.lambda_function_name
#   principal     = "events.amazonaws.com"
#   source_arn    = aws_cloudwatch_event_rule.legislation_table_update_trigger.arn
# }
