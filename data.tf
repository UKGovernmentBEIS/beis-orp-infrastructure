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
