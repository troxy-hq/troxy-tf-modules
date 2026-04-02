locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# Subnet Group
# ─────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.name_prefix}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# ─────────────────────────────────────────────
# Redis Replication Group (single node for MVP)
# ─────────────────────────────────────────────
resource "aws_elasticache_replication_group" "main" {
  replication_group_id = "${local.name_prefix}-redis"
  description          = "Troxy Redis — budget envelope tracking"

  engine               = "redis"
  engine_version       = var.redis_version
  node_type            = var.node_type
  num_cache_clusters   = 1 # single node for MVP

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = var.security_group_ids

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # simplifies Lambda connection for MVP

  auto_minor_version_upgrade = true
  maintenance_window         = "sun:05:00-sun:06:00"

  snapshot_retention_limit = 1
  snapshot_window          = "04:00-05:00"

  tags = {
    Name    = "${local.name_prefix}-redis"
    Project = var.project
    Env     = var.env
  }
}
