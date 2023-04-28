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

  email_configuration {
    email_sending_account  = "DEVELOPER"
    from_email_address     = "Open Regulation Platform <matt.whitfield@public.io>"
    reply_to_email_address = "matt.whitfield@public.io"
    source_arn             = "arn:aws:ses:${local.region}:${data.aws_caller_identity.current.account_id}:identity/matt.whitfield@public.io"
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
  domain       = "${local.environment}-beis-orp"
  user_pool_id = aws_cognito_user_pool.beis.id
}

resource "aws_cognito_user_pool" "beis_api" {
  name = "${local.environment}-beis-api"

  username_configuration {
    case_sensitive = false
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

  password_policy {
    minimum_length = 6
    require_lowercase = false
    require_uppercase = false
    require_numbers = false
    require_symbols = false
    temporary_password_validity_days = 7
  }
}

resource "aws_cognito_user_pool_client" "beis_api_client" {
  name = "${local.environment}-beis_api_client"
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
  domain       = "${local.environment}-beis-api"
  user_pool_id = aws_cognito_user_pool.beis_api.id
}
