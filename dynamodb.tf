resource "aws_dynamodb_table" "legislative-origin" {
  name           = "legislative-origin"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "candidate_titles"

  attribute {
    name = "candidate_titles"
    type = "S"
  }

  tags = {
    Name        = "legislative-origin"
    Environment = local.environment
  }
}
