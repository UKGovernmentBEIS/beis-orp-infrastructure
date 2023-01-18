module "db_postgresql" {
  source                         = "terraform-aws-modules/rds-aurora/aws"
  version                        = "7.1.0"
  name                           = "beis-orp-db"
  database_name                  = "beisorp"
  deletion_protection            = local.db_postgresql_config.deletion_protection
  engine                         = local.db_postgresql_config.engine
  engine_version                 = local.db_postgresql_config.engine_version
  vpc_id                         = module.vpc.vpc_id
  subnets                        = module.vpc.private_subnets
  create_security_group          = true
  security_group_use_name_prefix = false
  copy_tags_to_snapshot          = true
  # monitoring interval for enhanced monitoring 0 disables it, measured in seconds
  monitoring_interval             = local.db_postgresql_config.monitoring_interval
  apply_immediately               = true
  skip_final_snapshot             = false
  enable_http_endpoint            = local.db_postgresql_config.enable_http_endpoint
  db_parameter_group_name         = aws_db_parameter_group.db_pg_postgresql13.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_cpg_postgresql13.name
  master_username                 = "orp_client"
  create_random_password          = true

  serverlessv2_scaling_configuration = {
    min_capacity = local.db_postgresql_config.scaling_min_capacity
    max_capacity = local.db_postgresql_config.scaling_max_capacity
  }

  allowed_cidr_blocks = [
    module.vpc.vpc_cidr_block
  ]
  security_group_egress_rules = {
    egress = {
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  }
  random_password_length = 16

  instance_class = "db.serverless"
  instances = {
    one = {
    }
  }
}

resource "aws_db_parameter_group" "db_pg_postgresql13" {
  name        = "beis-orp-db-pg-${local.environment}"
  family      = "aurora-postgresql13"
  description = "beis-orp DB Aurora Postgres13 Parameter Group"
}

resource "aws_rds_cluster_parameter_group" "db_cpg_postgresql13" {
  name        = "beis-orp-db-cpg-${local.environment}"
  family      = "aurora-postgresql13"
  description = "beis-orp DB Aurora Postgres13 Cluster Parameter Group"
}
