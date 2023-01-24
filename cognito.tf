resource "aws_cognito_user_pool" "beis" {
  name = "beis"

  alias_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "beis_client" {
  name = "beis_client"

  user_pool_id = aws_cognito_user_pool.beis.id
}
