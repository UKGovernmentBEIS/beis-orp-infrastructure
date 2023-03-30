resource "aws_api_gateway_rest_api" "private_rest_api" {
  name        = "html_document_api"
  description = "Private REST API for HTML document uploads into the ORP"

  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_resource" "html_document_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.private_rest_api.root_resource_id
  path_part   = "html-document-api"
}

resource "aws_api_gateway_method" "html_document_api_post" {
  rest_api_id   = aws_api_gateway_rest_api.private_rest_api.id
  resource_id   = aws_api_gateway_resource.html_document_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "html_document_api_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private_rest_api.id
  resource_id             = aws_api_gateway_resource.html_document_api_resource.id
  http_method             = aws_api_gateway_method.html_document_api_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.html_trigger.lambda_function_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  request_templates = {
    "application/json" = jsonencode({
      "uuid": "$input.path('$.uuid')",
      "regulator_id": "$input.path('$.regulator_id')",
      "user_id": "$input.path('$.user_id')",
      "uri": "$input.path('$.uri')",
      "document_type": "$input.path('$.document_type')",
      "status": "$input.path('$.status')",
      "topics": "$input.path('$.topics')"
    })
  }
}

resource "aws_api_gateway_model" "html_document_api_request_model" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  name        = "html_document_api_request_model"
  content_type = "application/json"
  schema      = jsonencode({
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "HTML Trigger Request Model",
    "type": "object",
    "properties": {
      "uuid": {
        "type": "string",
        "format": "uuid"
      },
      "regulator_id": {
        "type": "string"
      },
      "user_id": {
        "type": "string",
        "format": "uuid"
      },
      "uri": {
        "type": "string",
        "format": "uri"
      },
      "document_type": {
        "type": "string",
        # "enum": ["GD", "PA", "TT", "MG"]
      },
      "status": {
        "type": "string",
        "enum": ["published", "draft"]
      },
      "topics": {
        "type": "array",
        "items": {
          "type": "string"
        }
      }
    },
    "required": ["uuid", "regulator_id", "user_id", "uri", "document_type", "status", "topics"],
    "additionalProperties": false
  })
}