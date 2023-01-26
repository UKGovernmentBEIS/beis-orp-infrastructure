module "beis_orp_documentdb_cluster" {
  source = "cloudposse/documentdb-cluster/aws"

  version      = "0.14.1"
  namespace    = "beis-orp"
  stage        = local.environment
  name         = "beis-orp"
  cluster_size = 3
  #  cluster_family = aws_docdb_cluster_parameter_group.default_docdb4_0.name
  master_username = "ddbadmin" # can't be admin :)
  master_password = "Test123456789"
  instance_class  = "db.r5.large"
  engine_version  = "3.6.0"
  vpc_id          = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],
    module.vpc.private_subnets[1],
    module.vpc.private_subnets[2]
  ]
  allowed_security_groups = [
    aws_security_group.documentdb_cluster.id
  ]
  zone_id = data.aws_route53_zone.app_domain.zone_id
}
