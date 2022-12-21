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

resource "aws_security_group" "documentdb_cluster" {
  name        = "beis-orp-documentdb-cluster"
  description = "Security Group for BEIS ORP DocumentDB Cluster"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "mongo_bastion_instance" {
  name        = "beis-orp-mongo-bastion-instance"
  description = "Security Group for BEIS ORP Mongo Bastion EC2 Instance"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "pdf_to_text_lambda" {
  name        = "beis-orp-pdf-to-text-lambda"
  description = "Security Group for BEIS ORP pdf-to-text Lambda"
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

resource "aws_security_group_rule" "keyword_extraction_lambda_to_documentdb" {
  from_port                = 27017
  protocol                 = "tcp"
  security_group_id        = aws_security_group.keyword_extraction_lambda.id
  to_port                  = 27017
  type                     = "egress"
  source_security_group_id = module.beis_orp_documentdb_cluster.security_group_id
}

resource "aws_security_group_rule" "documentdb_from_keyword_extraction_lambda" {
  from_port                = 27017
  protocol                 = "tcp"
  security_group_id        = module.beis_orp_documentdb_cluster.security_group_id
  to_port                  = 27017
  type                     = "ingress"
  source_security_group_id = aws_security_group.keyword_extraction_lambda.id
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

resource "aws_security_group_rule" "pdf_to_text_lambda_to_documentdb" {
  from_port                = 27017
  protocol                 = "tcp"
  security_group_id        = aws_security_group.pdf_to_text_lambda.id
  to_port                  = 27017
  type                     = "egress"
  source_security_group_id = module.beis_orp_documentdb_cluster.security_group_id
}

resource "aws_security_group_rule" "documentdb_from_pdf_to_text_lambda" {
  from_port                = 27017
  protocol                 = "tcp"
  security_group_id        = module.beis_orp_documentdb_cluster.security_group_id
  to_port                  = 27017
  type                     = "ingress"
  source_security_group_id = aws_security_group.pdf_to_text_lambda.id
}

resource "aws_security_group_rule" "ddb_default_sg_allow_27017" {
  from_port                = 27017
  protocol                 = "tcp"
  security_group_id        = module.beis_orp_documentdb_cluster.security_group_id
  to_port                  = 27017
  type                     = "ingress"
  source_security_group_id = aws_security_group.mongo_bastion_instance.id
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
