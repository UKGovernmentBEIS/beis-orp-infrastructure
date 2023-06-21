resource "aws_iam_role" "ecs_host" {
  name               = "ecs_webserver_host"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role" "ecs_svc" {
  name               = "ecs_webserver_svc"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "ecs_instance_policy" {
  name   = "ecs_webserver_instance_policy"
  policy = data.aws_iam_policy_document.ecs_instance.json
  role   = aws_iam_role.ecs_host.id
}

resource "aws_iam_role" "ecs_beis" {
  name               = "ecs_beis"
  assume_role_policy = data.aws_iam_policy_document.beis_ecs_assume_role.json
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_webserver_instance_profile"
  role = aws_iam_role.ecs_host.name
}

resource "aws_iam_role_policy" "ecs_svc_policy" {
  name   = "ecs_webserver_svc_policy"
  policy = data.aws_iam_policy_document.ecs_svc.json
  role   = aws_iam_role.ecs_svc.id
}

resource "aws_iam_role_policy_attachment" "multiple_policy" {
  for_each   = local.ecs_policies
  policy_arn = each.value
  role       = aws_iam_role.ecs_host.name
}

resource "aws_iam_instance_profile" "ec2_resource_ssm_profile" {
  name = "ec2_resource_ssm_profile"
  role = aws_iam_role.ec2_resource_ssm_profile.name
}

resource "aws_iam_role" "ec2_resource_ssm_profile" {
  name               = "dev-ssm-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = "test"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_resource_ssm_profile" {
  role       = aws_iam_role.ec2_resource_ssm_profile.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "typedb_iam_role" {
  name               = "typedb-${local.environment}-role"
  description        = "The role for use with the TypeDB Instance"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": {
"Effect": "Allow",
"Principal": {"Service": "ec2.amazonaws.com"},
"Action": "sts:AssumeRole"
}
}
EOF
  tags = {
    stack = local.environment
  }
}

resource "aws_iam_role_policy_attachment" "typedb_iam_role_sqs_access" {
  role       = aws_iam_role.typedb_iam_role.name
  policy_arn = aws_iam_policy.update_typedb_sqs_queue.arn
}

resource "aws_iam_role_policy_attachment" "typedb_iam_role_ssm_profile" {
  role       = aws_iam_role.typedb_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "typedb_instance_access_s3_policy" {
  name        = "TypeDB-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-graph-database.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "typedb_instance_access_s3_policy" {
  role       = aws_iam_role.typedb_iam_role.name
  policy_arn = aws_iam_policy.typedb_instance_access_s3_policy.arn
}

resource "aws_iam_instance_profile" "typedb_iam_profile" {
  name = "typedb_iam_profile"
  role = aws_iam_role.typedb_iam_role.name
}

resource "aws_iam_policy" "delete_document_lambda_s3_policy" {
  name        = "delete-document-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "orpml_ingest_lambda_s3_policy" {
  name        = "orpml-ingest-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "pdf_to_orpml_lambda_s3_policy" {
  name        = "pdf-to-orpml-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "docx_to_orpml_lambda_s3_policy" {
  name        = "docx-to-orpml-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "odf_to_orpml_lambda_s3_policy" {
  name        = "odf-to-orpml-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "html_to_orpml_lambda_s3_policy" {
  name        = "html-to-orpml-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-upload.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "check_duplicate_lambda_s3_policy" {
  name        = "check-duplicate-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "check_duplicate_lambda_cognito_policy" {
  name        = "check_duplicate_cognito"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:*"
        ],
        "Resource" : [
          aws_cognito_user_pool.beis.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "update_typedb_sqs_queue" {
  name        = "udpate-typedb-sqs-queue"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "*"
        ],
        "Resource" : [
          aws_sqs_queue.update_typedb.arn,
          aws_sqs_queue.update_typedb_deadletter.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "finalise_orpml_lambda_s3_policy" {
  name        = "finalise-orpml-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "typedb_ingestion_sqs" {
  name        = "typedb-ingestion-sqs-queue"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:SendMessage",
          "sqs:DeleteMessage",
          "sqs:ChangeMessageVisibility",
          "sqs:ReceiveMessage",
          "sqs:TagQueue",
          "sqs:UntagQueue",
          "sqs:PurgeQueue"
        ],
        "Resource" : [
          aws_sqs_queue.update_typedb.arn,
          aws_sqs_queue.update_typedb_deadletter.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "text_extraction_lambda_s3_policy" {
  name        = "text-extraction-Lambda-to-S3"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn,
          aws_s3_bucket.beis-orp-clustering-models.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "legislation_table_update_lambda_s3_policy" {
  name        = "legislation-table-update-lambda-s3-policy"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        "Resource" : [
          "arn:aws:s3:::*/*",
          aws_s3_bucket.beis-orp-datalake.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "legislation_table_update_secret_manager_policy" {
  name = "secret_manager_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:tna_credentials-*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_invoke_keyword_extraction" {
  name        = "lambda_invoke_keyword_extraction"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          module.keyword_extraction.lambda_function_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_invoke_typedb_ingestion" {
  name        = "lambda_invoke_typedb_ingest"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          module.typedb_ingestion.lambda_function_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_invoke_failure_notification" {
  name        = "lambda_invoke_failure_notification"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "lambda:InvokeFunction"
        ],
        "Resource" : [
          module.failure_notification.lambda_function_arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_access_dynamodb" {
  name        = "lambda_access_dynamodb"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ListAndDescribe",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ],
        "Resource" : [
          aws_dynamodb_table.legislative-origin.arn,
          "${aws_dynamodb_table.legislative-origin.arn}/index/year-candidate_titles-index"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "typedb_ingestion_cognito" {
  name        = "typedb_ingestion_cognito"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:*"
        ],
        "Resource" : [
          aws_cognito_user_pool.beis.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "failure_notification_cognito" {
  name        = "failure_notification_cognito"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cognito-idp:*"
        ],
        "Resource" : [
          aws_cognito_user_pool.beis.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "api_gateway_execution_role" {
  name = "api_gateway_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "api_gateway_execution_policy" {
  name = "api_gateway_execution_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          module.html_trigger.lambda_function_arn,
          module.delete_document.lambda_function_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution_attachment" {
  policy_arn = aws_iam_policy.api_gateway_execution_policy.arn
  role       = aws_iam_role.api_gateway_execution_role.name
}

resource "aws_iam_role" "legislation_update_eventbridge_role" {
  name = "eventbridge_schedule_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_lambda_policy_attachment" {
  policy_arn = aws_iam_policy.legislation_update_eventbridge_lambda_policy.arn
  role       = aws_iam_role.legislation_update_eventbridge_role.name
}

resource "aws_iam_policy" "legislation_update_eventbridge_lambda_policy" {
  name = "legislation_update_eventbridge_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.legislation_table_update.lambda_function_arn
      }
    ]
  })
}
