resource "aws_elasticache_cluster" "users" {
  cluster_id           = "${local.environment}-users"
  engine               = "redis"
  node_type            = "cache.m5.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
}
