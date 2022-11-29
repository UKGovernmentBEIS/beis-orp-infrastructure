#module "beis_orp_documentdb_cluster" {
#  source = "cloudposse/documentdb-cluster/aws"
#
#  version = "0.15.0"
#  namespace               = "beis-orp"
#  stage                   = local.environment
#  name                    = "beis-orp"
#  cluster_size            = 3
#  master_username         = "admin"
#  master_password         = "Test123456789"
#  instance_class          = "db.r4.large"
#  vpc_id                  = module.vpc.vpc_id
#  subnet_ids              = [
#    module.vpc.public_subnets[0],
#    module.vpc.public_subnets[1],
#    module.vpc.public_subnets[2]
#  ]
#  allowed_security_groups = []
#  # We will provide this once we have a domain name to use
##  zone_id                 = "Zxxxxxxxx"
#}
