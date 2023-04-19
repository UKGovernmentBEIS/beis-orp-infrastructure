resource "aws_sns_topic" "cloudwatch_alerts_topic" {
  name = "cloudwatch_alerts_topic"
}

resource "aws_sns_topic_policy" "cloudwatch_alerts_topic_policy" {
  arn = aws_sns_topic.cloudwatch_alerts_topic.arn

  policy = jsonencode(
    {
      Id = "__default_policy_ID"
      Statement = [
        {
          Action = [
            "SNS:GetTopicAttributes",
            "SNS:SetTopicAttributes",
            "SNS:AddPermission",
            "SNS:RemovePermission",
            "SNS:DeleteTopic",
            "SNS:Subscribe",
            "SNS:ListSubscriptionsByTopic",
            "SNS:Publish",
          ]
          Condition = {
            StringEquals = {
              "AWS:SourceOwner" = data.aws_caller_identity.current.account_id
            }
          }
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Resource = aws_sns_topic.cloudwatch_alerts_topic.arn
          Sid      = "__default_statement_ID"
        },
      ]
      Version = "2008-10-17"
    }
  )
}

resource "aws_sns_topic_subscription" "cloudwatch_alerts_subscription" {
  topic_arn = aws_sns_topic.cloudwatch_alerts_topic.arn
  protocol  = "email"
  endpoint  = local.alerting_config.alerting_email_address
}
