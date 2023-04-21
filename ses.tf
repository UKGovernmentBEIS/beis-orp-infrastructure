resource "aws_ses_email_identity" "email_notification_sender" {
  email = "OpenRegulationPlatform@beis.gov.uk"
}

resource "aws_iam_policy" "send_email_policy" {
  name_prefix = "send-email-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ses:FromAddress" : aws_ses_email_identity.email_notification_sender.email
          }
        }
      }
    ]
  })
}
