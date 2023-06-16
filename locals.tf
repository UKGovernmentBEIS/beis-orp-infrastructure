locals {
  package_url = var.package_url
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
  environment = var.environment
  region      = "eu-west-2"

  lambda_config = {
    typedb_search_query_image_ver = var.typedb_search_query_image_ver
  }

  html_trigger_config = {
    html_trigger_image_ver = var.html_trigger_image_ver
  }

  create_auth_challenge_config = {
    create_auth_challenge_image_ver = var.create_auth_challenge_image_ver
  }

  define_auth_challenge_config = {
    define_auth_challenge_image_ver = var.define_auth_challenge_image_ver
  }

  verify_auth_challenge_config = {
    verify_auth_challenge_image_ver = var.verify_auth_challenge_image_ver
  }

  delete_document_config = {
    delete_document_image_ver = var.delete_document_image_ver
  }

  orpml_ingest_config = {
    orpml_ingest_image_ver = var.orpml_ingest_image_ver
  }

  pdf_to_orpml_config = {
    pdf_to_orpml_image_ver = var.pdf_to_orpml_image_ver
  }

  docx_to_orpml_config = {
    docx_to_orpml_image_ver = var.docx_to_orpml_image_ver
  }

  odf_to_orpml_config = {
    odf_to_orpml_image_ver = var.odf_to_orpml_image_ver
  }

  html_to_orpml_config = {
    html_to_orpml_image_ver = var.html_to_orpml_image_ver
  }

  check_duplicate_config = {
    check_duplicate_image_ver = var.check_duplicate_image_ver
    cognito_user_pool         = aws_cognito_user_pool.beis.id
    sender_email_address      = var.typedb_ingestion_sender_email_address
  }

  title_generation_config = {
    title_generation_image_ver = var.title_generation_image_ver
  }

  date_generation_config = {
    date_generation_image_ver = var.date_generation_image_ver
  }

  keyword_extraction_config = {
    keyword_extraction_image_ver = var.keyword_extraction_image_ver
  }

  summarisation_config = {
    summarisation_image_ver = var.summarisation_image_ver
  }

  legislation_table_update_config = {
    legislation_table_update_image_ver = var.legislation_table_update_image_ver
  }

  legislative_origin_extraction_config = {
    legislative_origin_extraction_image_ver = var.legislative_origin_extraction_image_ver
    table_name                              = var.legislative_origin_extraction_table_name
    year_index_name                         = var.legislative_origin_extraction_year_index_name
  }

  typedb_backup_config = {
    typedb_backup_image_ver = var.typedb_backup_image_ver
  }

  finalise_orpml_config = {
    finalise_orpml_image_ver = var.finalise_orpml_image_ver
  }

  typedb_ingestion_config = {
    typedb_ingestion_image_ver = var.typedb_ingestion_image_ver
    destination_sqs_url        = aws_sqs_queue.update_typedb.url
    cognito_user_pool          = aws_cognito_user_pool.beis.id
    sender_email_address       = var.typedb_ingestion_sender_email_address
  }

  failure_notification_config = {
    failure_notification_image_ver = var.failure_notification_image_ver
  }

  typedb_config = {
    database_workdir       = var.database_workdir
    typedb_database_name   = var.typedb_database_name
    typedb_database_schema = var.typedb_database_schema
    typedb_database_file   = var.typedb_database_file
    typedb_docu_sqs_name   = var.typedb_docu_sqs_name
    typedb_server_port     = var.typedb_server_port
  }

  alerting_config = {
    alerting_email_address = var.alerting_email_address
  }
  #    prod = {
  #      database_workdir       = "graph_database"
  #      typedb_database_name   = "orp-mvp-v0.1"
  #      typedb_database_schema = "orp-gdb-schema.tql"
  #      typedb_database_file   = "orp-mvp-kgdb.typedb"
  #      typedb_docu_sqs_name   = "update-typedb"
  #      typedb_server_port     = 1729
  #    }

  #  webserver_config = {
  #    domain           = var.domain
  #    s3_upload_bucket = var.s3_upload_bucket
  #    mc_server        = var.mc_server
  #    mc_list          = var.mc_list
  #    orp_search_url   = var.orp_search_url
  #  }

  db_postgresql_config = {
    engine_version       = var.engine_version
    engine               = var.engine
    scaling_min_capacity = var.scaling_min_capacity
    scaling_max_capacity = var.scaling_max_capacity
    monitoring_interval  = var.monitoring_interval
    enable_http_endpoint = var.enable_http_endpoint
    deletion_protection  = var.deletion_protection
  }

  ecs_policies = {
    AmazonEC2ContainerServiceforEC2Role = var.AmazonEC2ContainerServiceforEC2Role
    AmazonSSMManagedInstanceCore        = var.AmazonSSMManagedInstanceCore
    CloudWatchLogsFullAccess            = var.CloudWatchLogsFullAccess
    AmazonECS_FullAccess                = var.AmazonECS_FullAccess
    NeptuneAccess                       = var.NeptuneAccess
  }

  ecs_config = {
    ecs_service_count     = var.ecs_service_count
    db_address            = var.db_address
    route_53_public_zone  = var.route_53_public_zone
    enable_monitoring     = var.enable_monitoring
    delete_on_termination = var.delete_on_termination
    encrypted_volume      = var.encrypted_volume
    volume_size           = var.volume_size
    template_file         = var.template_file
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html using lowest values for dev
    task_definition_cpu    = var.task_definition_cpu
    task_definition_memory = var.task_definition_memory
    autoscale = {
      autoscale_max_capacity = var.autoscale_max_capacity
      metric_name            = var.metric_name
      datapoints_to_alarm    = var.datapoints_to_alarm
      evaluation_periods     = var.evaluation_periods
      period                 = var.period
      cooldown               = var.cooldown
      adjustment_type        = var.adjustment_type

      #Cloudwatch Alarm Scale up and Scale down
      scale_up_threshold   = var.scale_up_threshold
      scale_down_threshold = var.scale_down_threshold

      #AutoScale Policy Scale up
      scale_up_comparison_operator  = var.scale_up_comparison_operator
      scale_up_interval_lower_bound = var.scale_up_interval_lower_bound
      scale_up_adjustment           = var.scale_up_adjustment

      #AutoScale Policy Scale down ###
      scale_down_comparison_operator  = var.scale_down_comparison_operator
      scale_down_interval_lower_bound = var.scale_down_interval_lower_bound
      scale_down_adjustment           = var.scale_down_adjustment
    }
  }
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

data "null_data_source" "downloaded_package" {
  inputs = {
    id       = null_resource.download_package.id
    filename = local.downloaded
  }
}

