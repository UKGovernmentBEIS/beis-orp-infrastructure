module "pdf_to_text" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4"

  function_name          = "pdf_to_text"
  handler                = "pdf_to_text.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/pdf-to-text:1.0.2"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.pdf_to_text_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT = local.environment
  }

  assume_role_policy_statements = {
    account_root = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        account_principal = {
          type        = "AWS",
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }
    }
    lambda = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        rds_principal = {
          type = "Service"
          identifiers = [
            "lambda.amazonaws.com",
          ]
        }
      }
    }
  }

  #Attaching AWS policies
  attach_policies = true
  policies = [
    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    aws_iam_policy.pdf_to_text_lambda_s3_policy.arn
  ]
  number_of_policies = 4

  #  allowed_triggers = {
  #    update_images = {
  #      principal  = "events.amazonaws.com"
  #      source_arn = module.eventbridge.eventbridge_rule_arns["update_images"]
  #    }
  #  }
}

module "typedb_search_query" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4"

  function_name          = "typedb_search_query"
  handler                = "handler.lambda_handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/typedb_search_query:v.0.1"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.typedb_search_query_lambda.id
  ]

  environment_variables = {
    ENVIRONMENT = local.environment,
    TYPEDB_SERVER_IP = aws_instance.typedb.private_ip,
    TYPEDB_SERVER_PORT = 1729,
    TYPEDB_DATABASE_NAME = "orp-mvp-v0.1" # hardcoded here and in ec2 userdata...
  }

  assume_role_policy_statements = {
    account_root = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        account_principal = {
          type        = "AWS",
          identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
        }
      }
    }
    lambda = {
      effect  = "Allow",
      actions = ["sts:AssumeRole"],
      principals = {
        rds_principal = {
          type = "Service"
          identifiers = [
            "lambda.amazonaws.com",
          ]
        }
      }
    }
  }

  #Attaching AWS policies
  attach_policies = true
  policies = [
#    "arn:aws:iam::aws:policy/AmazonECS_FullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
#    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
#    aws_iam_policy.pdf_to_text_lambda_s3_policy.arn
  ]
  number_of_policies = 1

  #  allowed_triggers = {
  #    update_images = {
  #      principal  = "events.amazonaws.com"
  #      source_arn = module.eventbridge.eventbridge_rule_arns["update_images"]
  #    }
  #  }
}
