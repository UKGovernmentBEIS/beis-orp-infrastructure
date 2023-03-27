resource "aws_dynamodb_table" "legislative-origin" {
  name         = "legislative-origin"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "candidate_titles"

  attribute {
    name = "candidate_titles"
    type = "S"
  }

  attribute {
    name = "year"
    type = "S"
  }

  global_secondary_index {
    name            = "year-candidate_titles-index"
    hash_key        = "year"
    range_key       = "candidate_titles"
    projection_type = "KEYS_ONLY"
  }

  tags = {
    Name        = "legislative-origin"
    Environment = local.environment
  }
}
