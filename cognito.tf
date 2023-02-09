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
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  access_token_validity = 60
  id_token_validity     = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  user_pool_id = aws_cognito_user_pool.beis.id
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "beis-orp"
  user_pool_id = aws_cognito_user_pool.beis.id
}

resource "aws_cognito_user_pool" "beis_api" {
  name = "beis-api"

  username_attributes = ["email"]

  auto_verified_attributes = [
    "email",
  ]

  user_attribute_update_settings {
    attributes_require_verification_before_update = [
      "email",
    ]
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_LINK"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "regulator"
    required                 = false
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
}

resource "aws_cognito_user_pool_client" "beis_api_client" {
  name = "beis_api_client"
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]

  access_token_validity = 60
  id_token_validity     = 60
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  user_pool_id = aws_cognito_user_pool.beis_api.id
}

resource "aws_cognito_user_pool_domain" "beis_api" {
  domain       = "beis-api"
  user_pool_id = aws_cognito_user_pool.beis_api.id
}
