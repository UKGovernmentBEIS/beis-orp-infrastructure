resource "aws_sqs_queue" "update_typedb" {
  name                      = "update-typedb"
  sqs_managed_sse_enabled   = false
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.update_typedb_deadletter.arn
    maxReceiveCount     = 4
  })

  tags = {
    Environment = local.environment
  }
}

resource "aws_sqs_queue" "update_typedb_deadletter" {
  name = "update-typedb-dlq"
  sqs_managed_sse_enabled = false
}
