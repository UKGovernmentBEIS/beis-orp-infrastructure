module "html_trigger" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "html_trigger"
  handler                = "html_trigger.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/html_trigger:${local.html_trigger_config.html_trigger_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true

  vpc_security_group_ids = [
    aws_security_group.html_trigger_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT       = local.environment
    STATE_MACHINE_ARN = aws_sfn_state_machine.sfn_state_machine.arn
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
    aws_iam_policy.policy_invoke_stepFunction.arn
  ]
  number_of_policies = 4
}

module "delete_document" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "delete_document"
  handler                = "delete_document.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/delete_document:${local.delete_document_config.delete_document_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true

  vpc_security_group_ids = [
    aws_security_group.delete_document_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT          = local.environment,
    TYPEDB_SERVER_IP     = aws_instance.typedb.private_ip,
    TYPEDB_SERVER_PORT   = local.typedb_config.typedb_server_port
    TYPEDB_DATABASE_NAME = local.typedb_config.typedb_database_name
    UPLOAD_BUCKET        = aws_s3_bucket.beis-orp-upload.id
    DATA_LAKE            = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.delete_document_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "orpml_ingest" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "orpml_ingest"
  handler                = "orpml_ingest.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/orpml_ingest:${local.orpml_ingest_config.orpml_ingest_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.orpml_ingest_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.orpml_ingest_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "pdf_to_orpml" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "pdf_to_orpml"
  handler                = "pdf_to_orpml.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/pdf_to_orpml:${local.pdf_to_orpml_config.pdf_to_orpml_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.pdf_to_orpml_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.pdf_to_orpml_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "docx_to_orpml" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "docx_to_orpml"
  handler                = "docx_to_orpml.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/docx_to_orpml:${local.docx_to_orpml_config.docx_to_orpml_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.docx_to_orpml_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.docx_to_orpml_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "odf_to_orpml" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "odf_to_orpml"
  handler                = "odf_to_orpml.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/odf_to_orpml:${local.odf_to_orpml_config.odf_to_orpml_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.odf_to_orpml_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.odf_to_orpml_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "html_to_orpml" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "html_to_orpml"
  handler                = "html_to_orpml.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/html_to_orpml:${local.html_to_orpml_config.html_to_orpml_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.html_to_orpml_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.html_to_orpml_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "check_duplicate" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "check_duplicate"
  handler                = "check_duplicate.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/check_duplicate:${local.check_duplicate_config.check_duplicate_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.check_duplicate_lambda.id
  ]

  environment_variables = {
    ENVIRONMENT          = local.environment,
    SOURCE_BUCKET        = aws_s3_bucket.beis-orp-datalake.id
    TYPEDB_SERVER_IP     = aws_instance.typedb.private_ip,
    TYPEDB_SERVER_PORT   = local.typedb_config.typedb_server_port
    TYPEDB_DATABASE_NAME = local.typedb_config.typedb_database_name
    TYPEDB_DATABASE_NAME = "orp-pbeta-v2"
    COGNITO_USER_POOL    = local.check_duplicate_config.cognito_user_pool
    SENDER_EMAIL_ADDRESS = local.check_duplicate_config.sender_email_address
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
    aws_iam_policy.check_duplicate_lambda_s3_policy.arn,
    aws_iam_policy.check_duplicate_lambda_cognito_policy.arn
  ]
  number_of_policies = 5
}

module "title_generation" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "title_generation"
  handler                = "title_generation.handler"
  runtime                = "python3.8"
  memory_size            = "3072"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/title_generation:${local.title_generation_config.title_generation_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.title_generation_lambda.id,
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
  ]
  number_of_policies = 3
}

module "date_generation" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "date_generation"
  handler                = "date_generation.handler"
  runtime                = "python3.8"
  memory_size            = "3072"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/date_generation:${local.date_generation_config.date_generation_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.date_generation_lambda.id,
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
  ]
  number_of_policies = 3
}

module "keyword_extraction" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "keyword_extraction"
  handler                = "keyword_extraction.handler"
  runtime                = "python3.8"
  memory_size            = "2048"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/keyword_extraction:${local.keyword_extraction_config.keyword_extraction_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.keyword_extraction_lambda.id,
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
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
  ]
  number_of_policies = 1
}

module "summarisation" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "summarisation"
  handler                = "summarisation.handler"
  runtime                = "python3.8"
  memory_size            = 4096
  ephemeral_storage_size = 4096
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/summarisation:${local.summarisation_config.summarisation_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.summarisation_lambda.id,
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
  ]
  number_of_policies = 3
}

module "legislation_table_update" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "legislation_table_update"
  handler                = "legislation_table_update.handler"
  runtime                = "python3.8"
  memory_size            = "1024"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/legislation_table_update:${local.legislation_table_update_config.legislation_table_update_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.legislation_table_update_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
    TABLE_NAME         = local.legislative_origin_extraction_config.table_name
    SECRET_NAME        = data.aws_secretsmanager_secret.tna_credentials.name
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
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    aws_iam_policy.legislation_table_update_lambda_s3_policy.arn,
    aws_iam_policy.lambda_access_dynamodb.arn,
    aws_iam_policy.legislation_table_update_secret_manager_policy.arn
  ]
  number_of_policies = 4
}

module "legislative_origin_extraction" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "legislative_origin_extraction"
  handler                = "legislative_origin_extraction.handler"
  runtime                = "python3.8"
  memory_size            = "3072"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/legislative_origin_extraction:${local.legislative_origin_extraction_config.legislative_origin_extraction_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.legislative_origin_extraction_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT     = local.environment
    TABLE_NAME      = local.legislative_origin_extraction_config.table_name
    YEAR_INDEX_NAME = local.legislative_origin_extraction_config.year_index_name
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
    aws_iam_policy.lambda_access_dynamodb.arn
  ]
  number_of_policies = 4
}

module "finalise_orpml" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "finalise_orpml"
  handler                = "finalise_orpml.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/finalise_orpml:${local.finalise_orpml_config.finalise_orpml_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.finalise_orpml_lambda.id,
    module.vpc.default_security_group_id
  ]

  environment_variables = {
    ENVIRONMENT        = local.environment
    SOURCE_BUCKET      = aws_s3_bucket.beis-orp-datalake.id
    DESTINATION_BUCKET = aws_s3_bucket.beis-orp-datalake.id
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
    aws_iam_policy.finalise_orpml_lambda_s3_policy.arn
  ]
  number_of_policies = 4
}

module "typedb_ingestion" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "typedb_ingestion"
  handler                = "typedb_ingestion.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/typedb_ingestion:${local.typedb_ingestion_config.typedb_ingestion_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.typedb_ingestion_lambda.id,
    aws_security_group.sqs_vpc_endpoint.id
  ]

  environment_variables = {
    ENVIRONMENT          = local.environment
    DESTINATION_SQS_URL  = local.typedb_ingestion_config.destination_sqs_url
    COGNITO_USER_POOL    = aws_cognito_user_pool.beis.id
    SENDER_EMAIL_ADDRESS = local.typedb_ingestion_config.sender_email_address
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
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    aws_iam_policy.text_extraction_lambda_s3_policy.arn,
    aws_iam_policy.typedb_ingestion_sqs.arn,
    aws_iam_policy.typedb_ingestion_cognito.arn,
    aws_iam_policy.send_email_policy.arn
  ]
  number_of_policies = 6
}

module "failure_notification" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "failure_notification"
  handler                = "failure_notification.handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/failure_notification:${local.failure_notification_config.failure_notification_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  vpc_security_group_ids = [
    aws_security_group.failure_notification_lambda.id,
    aws_security_group.sqs_vpc_endpoint.id
  ]

  environment_variables = {
    ENVIRONMENT          = local.environment
    COGNITO_USER_POOL    = local.typedb_ingestion_config.cognito_user_pool
    SENDER_EMAIL_ADDRESS = local.typedb_ingestion_config.sender_email_address
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
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    aws_iam_policy.text_extraction_lambda_s3_policy.arn,
    aws_iam_policy.failure_notification_cognito.arn,
    aws_iam_policy.send_email_policy.arn
  ]
  number_of_policies = 5
}

module "typedb_search_query" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.1.2"

  function_name          = "typedb_search_query"
  handler                = "handler.lambda_handler"
  runtime                = "python3.8"
  memory_size            = "512"
  timeout                = 900
  create_package         = false
  image_uri              = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/typedb_search_query:${local.lambda_config.typedb_search_query_image_ver}"
  package_type           = "Image"
  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true


  vpc_security_group_ids = [
    aws_security_group.typedb_search_query_lambda.id
  ]

  environment_variables = {
    ENVIRONMENT          = local.environment,
    TYPEDB_SERVER_IP     = aws_instance.typedb.private_ip,
    TYPEDB_SERVER_PORT   = local.typedb_config.typedb_server_port
    TYPEDB_DATABASE_NAME = local.typedb_config.typedb_database_name
    NLTK_DATA            = "./nltk_data"
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
    #    aws_iam_policy.update_typedb_sqs_queue.arn
  ]
  number_of_policies = 1

  #  allowed_triggers = {
  #    update_images = {
  #      principal  = "events.amazonaws.com"
  #      source_arn = module.eventbridge.eventbridge_rule_arns["update_images"]
  #    }
  #  }
}

module "create_auth_challenge" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.18.0"

  function_name  = "create_auth_challenge"
  memory_size    = "512"
  timeout        = 900
  create_package = false
  image_uri      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/create_auth_challenge:${local.create_auth_challenge_config.create_auth_challenge_image_ver}"
  package_type   = "Image"
  #  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true

  environment_variables = {
    SES_FROM_ADDRESS = "orp@public.io"
    ENV_HREF         = aws_route53_record.app.fqdn
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
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
  number_of_policies = 3
}

module "define_auth_challenge" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.18.0"

  function_name  = "define_auth_challenge"
  memory_size    = "512"
  timeout        = 900
  create_package = false
  image_uri      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/define_auth_challenge:${local.define_auth_challenge_config.define_auth_challenge_image_ver}"
  package_type   = "Image"
  #  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true

  environment_variables = {
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
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
  number_of_policies = 3
}

module "verify_auth_challenge" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.18.0"

  function_name  = "verify_auth_challenge"
  memory_size    = "512"
  timeout        = 900
  create_package = false
  image_uri      = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com/verify_auth_challenge:${local.verify_auth_challenge_config.verify_auth_challenge_image_ver}"
  package_type   = "Image"
  #  vpc_subnet_ids         = module.vpc.private_subnets
  maximum_retry_attempts = 0
  attach_network_policy  = true

  create_current_version_allowed_triggers = false

  # Function URL Config
  create_lambda_function_url                   = true
  authorization_type                           = "NONE"
  create_unqualified_alias_lambda_function_url = true

  environment_variables = {
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
    "arn:aws:iam::aws:policy/AmazonSESFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
  ]
  number_of_policies = 3
}
