module "beis_orp_documentdb_cluster" {
  source = "cloudposse/documentdb-cluster/aws"

  version = "0.15.0"
  namespace               = "beis-orp"
  stage                   = local.environment
  name                    = "beis-orp"
  cluster_size            = 3
#  cluster_family = aws_docdb_cluster_parameter_group.default_docdb4_0.name
  master_username         = "ddbadmin"  # can't be admin :)
  master_password         = "Test123456789"
  instance_class          = "db.r5.large"
  engine_version = "3.6.0"
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = [
    module.vpc.public_subnets[0],
    module.vpc.public_subnets[1],
    module.vpc.public_subnets[2]
  ]
  allowed_security_groups = [
    aws_security_group.documentdb_cluster.id
  ]
  # We will provide this once we have a domain name to use
#  zone_id                 = "Zxxxxxxxx"
}
#
##resource "aws_docdb_cluster_parameter_group" "default_docdb4_0" {
##  family      = "docdb4.0"
##  name        = "defaultdocdb40"
##  description = "docdb cluster parameter group 4.0"
##
##  parameter {
##    name  = "tls"
##    value = "enabled"
##  }
##}
