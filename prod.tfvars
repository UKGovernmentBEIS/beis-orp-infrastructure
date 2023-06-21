package_url = "https://github.com/mdrxtech/beis-orp-application/archive/refs/tags/v0.0.1.zip"
tf_profile  = "personal"
environment = "prod"
region      = "eu-west-2"

html_trigger_image_ver                  = "latest"
create_auth_challenge_image_ver         = "latest"
define_auth_challenge_image_ver         = "latest"
verify_auth_challenge_image_ver         = "latest"
delete_document_image_ver               = "latest"
orpml_ingest_image_ver                  = "latest"
pdf_to_orpml_image_ver                  = "latest"
docx_to_orpml_image_ver                 = "latest"
odf_to_orpml_image_ver                  = "latest"
html_to_orpml_image_ver                 = "latest"
check_duplicate_image_ver               = "latest"
title_generation_image_ver              = "latest"
date_generation_image_ver               = "latest"
keyword_extraction_image_ver            = "latest"
summarisation_image_ver                 = "latest"
legislative_origin_extraction_image_ver = "latest"
legislation_table_update_image_ver      = "latest"
finalise_orpml_image_ver                = "latest"
typedb_ingestion_image_ver              = "latest"
failure_notification_image_ver          = "latest"
typedb_search_query_image_ver           = "latest"
typedb_backup_image_ver                 = "latest"

legislative_origin_extraction_table_name      = "legislative-origin"
legislative_origin_extraction_year_index_name = "year-candidate_titles-index"
typedb_ingestion_sender_email_address         = "OpenRegulationPlatform@beis.gov.uk"
destination_sqs_url                           = aws_sqs_queue.update_typedb.url

database_workdir       = "graph_database"
typedb_database_name   = "test-orp-pbeta"
typedb_database_schema = "orp-gdb-schema.tql"
typedb_database_file   = "orp-mvp-kgdb.typedb"
typedb_docu_sqs_name   = "update-typedb"
typedb_server_port     = 1729

alerting_email_address = "OpenRegulationPlatform@beis.gov.uk"

regulator_access = "public.io,mdrx.tech,beis.gov.uk,businessandtrade.gov.uk"

#domain           = "https://app.dev.bre-orp-alpha.io/"
#s3_upload_bucket = "beis-prod-upload"
# s3_data_lake     = "beis-orp-dev-datalake"
# s3_model_bucket  = "beis-orp-dev-clustering-models"
mc_server = "us13"
mc_list   = "d8234fcc62"
#orp_search_url = "https://laomv22gzq5iqmlnnaqazug7vy0menni.lambda-url.eu-west-2.on.aws"

engine_version       = "13.7"
engine               = "aurora-postgresql"
scaling_min_capacity = "0.5"
scaling_max_capacity = "1.0"
monitoring_interval  = "0"
enable_http_endpoint = false
deletion_protection  = false

AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
CloudWatchLogsFullAccess            = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
AmazonECS_FullAccess                = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
NeptuneAccess                       = "arn:aws:iam::aws:policy/NeptuneFullAccess"


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

