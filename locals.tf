locals {
  package_url = "https://github.com/mdrxtech/beis-orp-application/archive/refs/tags/v0.0.1.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"

  environment = terraform.workspace == "default" ? "dev" : terraform.workspace
  region      = "eu-west-2"

  webserver_config = {
    dev = {
      domain            = "https://app.dev.cannonband.com/"
      s3_upload_bucket  = "beis-orp-dev-upload"
      mc_server         = "us13"
      mc_list           = "d8234fcc62"
      orp_search_lambda = "https://laomv22gzq5iqmlnnaqazug7vy0menni.lambda-url.eu-west-2.on.aws"
    }
  }

  db_postgresql_config = {
    engine_version       = "13.7"
    engine               = "aurora-postgresql"
    scaling_min_capacity = "0.5"
    scaling_max_capacity = "1.0"
    monitoring_interval  = "0"
    enable_http_endpoint = false
    deletion_protection  = false
  }

  ecs_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    CloudWatchLogsFullAccess            = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    AmazonECS_FullAccess                = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
    NeptuneAccess                       = "arn:aws:iam::aws:policy/NeptuneFullAccess"
  }

  ecs_config = {
    ecs_service_count     = "1"
    db_address            = "db.beis.com"
    route_53_public_zone  = "dev.beis.com"
    enable_monitoring     = false
    delete_on_termination = true
    encrypted_volume      = false
    volume_size           = "30"
    template_file         = "app.json"
    # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html using lowest values for dev
    task_definition_cpu    = "256"
    task_definition_memory = "512"
    autoscale = {
      autoscale_max_capacity = 5
      metric_name            = "CPUUtilization"
      datapoints_to_alarm    = 1
      evaluation_periods     = 1
      period                 = 60
      cooldown               = 60
      adjustment_type        = "ChangeInCapacity"

      #Cloudwatch Alarm Scale up and Scale down
      scale_up_threshold   = 70
      scale_down_threshold = 40

      #AutoScale Policy Scale up
      scale_up_comparison_operator  = "GreaterThanOrEqualToThreshold"
      scale_up_interval_lower_bound = 1
      scale_up_adjustment           = 1

      #AutoScale Policy Scale down ###
      scale_down_comparison_operator  = "LessThanThreshold"
      scale_down_interval_lower_bound = 0
      scale_down_adjustment           = -1
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
