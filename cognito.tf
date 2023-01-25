resource "aws_cognito_user_pool" "beis" {
  name = "beis"

  username_attributes = ["email"]

  auto_verified_attributes = [ "email"]

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }
}

resource "aws_cognito_user_pool_client" "beis_client" {
  name = "beis_client"

  user_pool_id = aws_cognito_user_pool.beis.id
}
