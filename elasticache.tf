resource "aws_elasticache_cluster" "users" {
  cluster_id           = "${local.environment}-users"
  engine               = "redis"
  node_type            = "cache.m5.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.2"
  port                 = 6379
  security_group_ids   = [aws_security_group.ec_cluster.id]
  subnet_group_name    = aws_elasticache_subnet_group.ecs.name
}
