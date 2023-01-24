resource "aws_cognito_user_pool" "beis" {
  name = "beis"

  alias_attributes = ["email"]
}
