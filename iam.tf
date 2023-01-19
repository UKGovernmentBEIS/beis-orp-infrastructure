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

resource "aws_iam_policy" "pdf_to_text_lambda_s3_policy" {
  name        = "pdf-to-text-Lambda-to-S3"
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

resource "aws_iam_policy" "text_extraction_to_document_db" {
  name        = "text-extraction-to-document-db"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "docdb-elastic:*"
        ],
        "Resource" : [
          module.beis_orp_documentdb_cluster.arn
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

resource "aws_iam_policy" "typedb_ingestion_to_document_db" {
  name        = "typedb-ingestion-to-document-db"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "docdb-elastic:*"
        ],
        "Resource" : [
          module.beis_orp_documentdb_cluster.arn
        ]
      }
    ]
  })
}

#resource "aws_iam_policy" "typedb_search_query_to_document_db" {
#  name        = "typedb-search-query-to-document-db"
#  path        = "/"
#  description = "Allow "
#
#  policy = jsonencode({
#    "Version" : "2012-10-17",
#    "Statement" : [
#      {
#        "Effect" : "Allow",
#        "Action" : [
#          "docdb-elastic:*"
#        ],
#        "Resource" : [
#          module.beis_orp_documentdb_cluster.arn
#        ]
#      }
#    ]
#  })
#}

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
          aws_s3_bucket.beis-orp-datalake.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "bertopic_inference_to_s3" {
  name        = "bertopic-inference-Lambda-to-S3"
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
          aws_s3_bucket.beis-orp-datalake.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "bertopic_inference_to_document_db" {
  name        = "bertopic-inference-to-document-db"
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "docdb-elastic:*"
        ],
        "Resource" : [
          module.beis_orp_documentdb_cluster.arn
        ]
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
