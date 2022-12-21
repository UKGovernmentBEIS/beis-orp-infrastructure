data "aws_iam_policy_document" "assume_role" {
  statement {
    sid    = "AssumeRole"
    effect = "Allow"
    principals {
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "rds.amazonaws.com",
      ]
      type = "Service"
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecs_beis"
      ]
      type = "AWS"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "beis_ecs_assume_role" {
  statement {
    sid    = "RDS"
    effect = "Allow"
    principals {
      identifiers = [
        "ec2.amazonaws.com",
        "ecs.amazonaws.com",
        "rds.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      type = "Service"
    }
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
      type = "AWS"
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

data "aws_iam_policy_document" "ecs_instance" {
  statement {
    sid       = "InstancePolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "ecs:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "ecr:*",
      "cloudwatch:*",
      "s3:*",
      "rds:*",
      "logs:*",
      "secretsmanager:*",
    ]
  }
}

data "aws_iam_policy_document" "ecs_svc" {
  statement {
    sid       = "ServicePolicy"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "ec2:Describe*",
      "ec2:AuthorizeSecurityGroupIngress",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]
  }
}

data "aws_secretsmanager_secret" "mc_api_key" {
  name = "mc_api_key_${local.environment}"
}

data "aws_secretsmanager_secret_version" "mc_api_key" {
  secret_id = data.aws_secretsmanager_secret.mc_api_key.id
}

data "aws_secretsmanager_secret" "api_upload_key" {
  name = "api_upload_key_${local.environment}"
}

data "aws_secretsmanager_secret_version" "api_upload_key" {
  secret_id = data.aws_secretsmanager_secret.api_upload_key.id
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${local.region}.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = aws_vpc_endpoint.private_s3.prefix_list_id
}

#data "template_file" "typedb" {
#  template = "${file("${path.module}/files/typedb-userdata.tpl")}"
#  vars = {
#    aws_region = local.region,
#    database_workdir = local.typedb_config[local.environment].database_workdir,
#    typedb_database_name = local.typedb_config[local.environment].typedb_database_name,
#    typedb_database_schema = local.typedb_config[local.environment].typedb_database_schema,
#    typedb_database_file = local.typedb_config[local.environment].typedb_database_file,
#    typedb_docu_sqs_name = local.typedb_config[local.environment].typedb_docu_sqs_name
#  }
#}
