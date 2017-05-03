resource "aws_elasticache_cluster" "sample" {
  cluster_id = "sample"
  engine = "redis"
  node_type = "cache.t2.small"
  num_cache_nodes = 1
  parameter_group_name = "default.redis3.2"
  port = 6379
}

output "endpoint" {
  value = "${aws_elasticache_cluster.sample.cache_nodes.0.address}"
}
