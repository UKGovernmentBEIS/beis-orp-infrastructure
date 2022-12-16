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
