resource "aws_api_gateway_rest_api" "private_rest_api" {
  name        = "orp_document_api"
  description = "Private REST API to interact directly with the ORP pipeline and database"

  endpoint_configuration {
    types = ["PRIVATE"]
  }
}

resource "aws_api_gateway_deployment" "private_rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
#  stage_name  = var.environment
  description = "${var.environment} deployment of the private ORP pipeline REST API"
  depends_on = [
    aws_api_gateway_integration.html_ingestion_lambda_integration,
    aws_api_gateway_integration.delete_lambda_integration,
  ]
}

resource "aws_api_gateway_stage" "private_rest_api_stage" {
  rest_api_id   = aws_api_gateway_rest_api.private_rest_api.id
  deployment_id = aws_api_gateway_deployment.private_rest_api_deployment.id
  stage_name    = var.environment
  description   = "${var.environment} stage of the private ORP pipeline REST API"
}

resource "aws_api_gateway_rest_api_policy" "private_rest_api_policy_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "execute-api:Invoke",
        "Resource" : "${aws_api_gateway_rest_api.private_rest_api.arn}/*"
      },
      {
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "execute-api:Invoke",
        "Resource" : "${aws_api_gateway_rest_api.private_rest_api.arn}/*",
        "Condition" : {
          "StringNotEquals" : {
            "aws:SourceVpc" : module.vpc.vpc_id
          }
        }
      }
    ]
  })
}

# HTML Ingestion API Resource
resource "aws_api_gateway_resource" "html_ingestion_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.private_rest_api.root_resource_id
  path_part   = "html-document-ingestion"
}

resource "aws_api_gateway_method" "html_document_post" {
  rest_api_id          = aws_api_gateway_rest_api.private_rest_api.id
  resource_id          = aws_api_gateway_resource.html_ingestion_resource.id
  http_method          = "POST"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.html_document_validator.id
  request_parameters = {
    "method.request.header.Content-Type" = false
  }
  request_models = {
    "application/json" = aws_api_gateway_model.request_validator_model.name
  }
}

resource "aws_api_gateway_integration" "html_ingestion_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private_rest_api.id
  resource_id             = aws_api_gateway_resource.html_ingestion_resource.id
  http_method             = aws_api_gateway_method.html_document_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/${module.html_trigger.lambda_function_arn}/invocations"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  content_handling        = "CONVERT_TO_TEXT"
  credentials             = aws_iam_role.api_gateway_execution_role.arn
}

resource "aws_api_gateway_integration_response" "html_ingestion_lambda_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  resource_id = aws_api_gateway_resource.html_ingestion_resource.id
  http_method = aws_api_gateway_method.html_document_post.http_method
  status_code = "200"
  response_templates = {
    "application/json" = ""
  }
  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "html_ingestion_response_200" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  resource_id = aws_api_gateway_resource.html_ingestion_resource.id
  http_method = aws_api_gateway_method.html_document_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.empty_response_model.name
  }
  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_request_validator" "html_document_validator" {
  name        = "html_document_validator"
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id

  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_model" "request_validator_model" {
  rest_api_id  = aws_api_gateway_rest_api.private_rest_api.id
  name         = "requestValidator"
  content_type = "application/json"
  schema = jsonencode({
    "$schema" : "http://json-schema.org/draft-04/schema#",
    "title" : "HTML Trigger Request Model",
    "type" : "object",
    "properties" : {
      "uuid" : {
        "type" : "string",
        "format" : "uuid"
      },
      "regulator_id" : {
        "type" : "string"
      },
      "user_id" : {
        "type" : "string",
        "format" : "uuid"
      },
      "uri" : {
        "type" : "string",
        "format" : "uri"
      },
      "document_type" : {
        "type" : "string",
        # "enum": ["GD", "PA", "TT", "MG"]
      },
      "status" : {
        "type" : "string",
        "enum" : ["published", "draft"]
      },
      "topics" : {
        "type" : "array",
        "items" : {
          "type" : "string"
        }
      }
    },
    "required" : ["uuid", "regulator_id", "user_id", "uri", "document_type", "status", "topics"],
    "additionalProperties" : false
  })
}

resource "aws_api_gateway_model" "empty_response_model" {
  rest_api_id  = aws_api_gateway_rest_api.private_rest_api.id
  name         = "emptyResponseModel"
  content_type = "application/json"
  schema       = jsonencode({})
}

# Delete Document API Resource
resource "aws_api_gateway_resource" "delete_document_resource" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  parent_id   = aws_api_gateway_rest_api.private_rest_api.root_resource_id
  path_part   = "delete-document"
}

resource "aws_api_gateway_method" "delete_document" {
  rest_api_id          = aws_api_gateway_rest_api.private_rest_api.id
  resource_id          = aws_api_gateway_resource.delete_document_resource.id
  http_method          = "DELETE"
  authorization        = "NONE"
  request_validator_id = aws_api_gateway_request_validator.delete_validator.id
  request_parameters = {
    "method.request.header.Content-Type" = false
  }
  request_models = {
    "application/json" = aws_api_gateway_model.delete_validator_model.name
  }
}

resource "aws_api_gateway_integration" "delete_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.private_rest_api.id
  resource_id             = aws_api_gateway_resource.delete_document_resource.id
  http_method             = aws_api_gateway_method.delete_document.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/${module.delete_document.lambda_function_arn}/invocations"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
  content_handling        = "CONVERT_TO_TEXT"
  credentials             = aws_iam_role.api_gateway_execution_role.arn
}

resource "aws_api_gateway_integration_response" "delete_lambda_integration_response_200" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  resource_id = aws_api_gateway_resource.delete_document_resource.id
  http_method = aws_api_gateway_method.delete_document.http_method
  status_code = "200"
  response_templates = {
    "application/json" = ""
  }
  content_handling = "CONVERT_TO_TEXT"
}

resource "aws_api_gateway_method_response" "delete_response_200" {
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id
  resource_id = aws_api_gateway_resource.delete_document_resource.id
  http_method = aws_api_gateway_method.delete_document.http_method
  status_code = "200"
  response_models = {
    "application/json" = aws_api_gateway_model.empty_response_model.name
  }
  response_parameters = {
    "method.response.header.Content-Type" = true
  }
}

resource "aws_api_gateway_request_validator" "delete_validator" {
  name        = "delete_validator"
  rest_api_id = aws_api_gateway_rest_api.private_rest_api.id

  validate_request_body       = true
  validate_request_parameters = false
}

resource "aws_api_gateway_model" "delete_validator_model" {
  rest_api_id  = aws_api_gateway_rest_api.private_rest_api.id
  name         = "deleteValidator"
  content_type = "application/json"
  schema = jsonencode({
    "$schema" : "http://json-schema.org/draft-04/schema#",
    "title" : "Document Delete Request Model",
    "type" : "object",
    "properties" : {
      "uuid" : {
        "type" : "string",
        "format" : "uuid"
      },
      "regulator_id" : {
        "type" : "string"
      }
    }
    "required" : ["uuid", "regulator_id"],
    "additionalProperties" : false
  })
}
