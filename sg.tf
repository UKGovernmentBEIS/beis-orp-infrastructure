resource "aws_security_group" "ecs" {
  name        = "beis-orp-ecs"
  description = "Security Group for BEIS ORP ECS"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "alb" {
  name        = "beis-orp-alb"
  description = "Security Group for BEIS ORP ECS ALB"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "typedb_instance" {
  name        = "beis-orp-typedb-instance"
  description = "Security Group for BEIS ORP TypeDB EC2 Instance"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "typedb_instance_s3_pfl" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.typedb_instance.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = [data.aws_prefix_list.private_s3.cidr_blocks[0]]
}

resource "aws_security_group" "mongo_bastion_instance" {
  name        = "beis-orp-mongo-bastion-instance"
  description = "Security Group for BEIS ORP Mongo Bastion EC2 Instance"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "html_trigger_lambda" {
  name        = "beis-orp-html-trigger-lambda"
  description = "Security Group for BEIS ORP html_trigger Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "pdf_to_text_lambda" {
  name        = "beis-orp-pdf-to-text-lambda"
  description = "Security Group for BEIS ORP pdf-to-text Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "docx_to_text_lambda" {
  name        = "beis-orp-docx-to-text-lambda"
  description = "Security Group for BEIS ORP docx-to-text Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "odf_to_text_lambda" {
  name        = "beis-orp-odf-to-text-lambda"
  description = "Security Group for BEIS ORP odf-to-text Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "html_to_text_lambda" {
  name        = "beis-orp-html-to-text-lambda"
  description = "Security Group for BEIS ORP html-to-text Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "check_duplicates_lambda" {
  name        = "beis-orp-check-duplicates-lambda"
  description = "Security Group for BEIS ORP check_duplicate Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "title_generation_lambda" {
  name        = "beis-orp-title-generation-lambda"
  description = "Security Group for BEIS ORP title-generation Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "date_generation_lambda" {
  name        = "beis-orp-date-generation-lambda"
  description = "Security Group for BEIS ORP date-generation Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "summarisation_lambda" {
  name        = "beis-orp-summarisation-lambda"
  description = "Security Group for BEIS ORP summarisation Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "legislative_origin_extraction_lambda" {
  name        = "beis-orp-legislative-origin-extraction-lambda"
  description = "Security Group for BEIS ORP legislative-origin-extraction Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "typedb_search_query_lambda" {
  name        = "beis-orp-typedb-search-query-lambda"
  description = "Security Group for BEIS ORP typedb-search-query Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "keyword_extraction_lambda" {
  name        = "beis-orp-extraction-keyword-lambda"
  description = "Security Group for BEIS ORP extraction-keyword Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "typedb_ingestion_lambda" {
  name        = "beis-orp-typedb-ingestion-lambda"
  description = "Security Group for BEIS ORP typedb_ingestion Lambda"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "sqs_vpc_endpoint" {
  name        = "beis-orp-sqs-vpc-endpoint"
  description = "Security Group for BEIS ORP SQS VPC Endpoint"
  vpc_id      = module.vpc.vpc_id
}

# Because AWS is annoying sometimes
resource "aws_security_group_rule" "sqs_vpc_endpoint_ingress_all" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.sqs_vpc_endpoint.id
  to_port           = 65535
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "typedb_search_query_lambda_to_typedb_instance" {
  from_port                = local.typedb_config.typedb_server_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.typedb_search_query_lambda.id
  to_port                  = local.typedb_config.typedb_server_port
  type                     = "egress"
  source_security_group_id = aws_security_group.typedb_instance.id
}

resource "aws_security_group_rule" "typedb_instance_from_typedb_search_query_lambda" {
  from_port                = local.typedb_config.typedb_server_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.typedb_instance.id
  to_port                  = local.typedb_config.typedb_server_port
  type                     = "ingress"
  source_security_group_id = aws_security_group.typedb_search_query_lambda.id
}

resource "aws_security_group_rule" "typedb_ingestion_lambda_to_sqs_endpoint" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.typedb_ingestion_lambda.id
  to_port                  = 443
  type                     = "egress"
  source_security_group_id = aws_security_group.sqs_vpc_endpoint.id
}
  
resource "aws_security_group_rule" "typedb_ingestion_all_outgoing" {
  from_port                = 0
  protocol                 = "tcp"
  security_group_id        = aws_security_group.typedb_ingestion_lambda.id
  to_port                  = 65535
  type                     = "egress"
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "keyword_extraction_lambda_s3_pfl" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.keyword_extraction_lambda.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = [data.aws_prefix_list.private_s3.cidr_blocks[0]]
}

resource "aws_security_group_rule" "pdf_to_text_lambda_s3_pfl" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.pdf_to_text_lambda.id
  to_port           = 443
  type              = "egress"
  cidr_blocks       = [data.aws_prefix_list.private_s3.cidr_blocks[0]]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_all" {
  from_port         = 0
  protocol          = "tcp"
  security_group_id = aws_security_group.alb.id
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "webserver_ingress_ping" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  to_port           = -1
  type              = "ingress"
  cidr_blocks = [
    module.vpc.vpc_cidr_block
  ]
}

resource "aws_security_group_rule" "webserver_egress_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs.id
  to_port           = 65535
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
