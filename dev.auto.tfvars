package_url = "https://github.com/mdrxtech/beis-orp-application/archive/refs/tags/v0.0.1.zip"
tf_profile = "terraform-dev"
environment = "dev"
region      = "eu-west-2"

pdf_to_text_image_ver         = "1.2.3"
typedb_search_query_image_ver = "v.0.1"
keyword_extraction_image_ver  = "5.1"
typedb_ingestion_image_ver    = "0.4"
bertopic_inference_image_ver  = "7.6"
pdf_to_text_image_uri         = "1.2.2"

database_workdir       = "graph_database"
typedb_database_name   = "orp-mvp-v0.1"
typedb_database_schema = "orp-gdb-schema.tql"
typedb_database_file   = "orp-mvp-kgdb.typedb"
typedb_docu_sqs_name   = "update-typedb"
typedb_server_port     = 1729


domain           = "https://app.dev.cannonband.com/"
s3_upload_bucket = "beis-orp-dev-upload"
mc_server        = "us13"
mc_list          = "d8234fcc62"
orp_search_url   = "https://laomv22gzq5iqmlnnaqazug7vy0menni.lambda-url.eu-west-2.on.aws"

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
