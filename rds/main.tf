locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# DB Subnet Group
# ─────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name    = "${local.name_prefix}-db-subnet-group"
    Project = var.project
    Env     = var.env
  }
}

# ─────────────────────────────────────────────
# Parameter Group
# ─────────────────────────────────────────────
resource "aws_db_parameter_group" "main" {
  name   = "${local.name_prefix}-pg16"
  family = "postgres${var.postgres_version}"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Project = var.project
    Env     = var.env
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────
# RDS PostgreSQL Instance
# ─────────────────────────────────────────────
resource "aws_db_instance" "main" {
  identifier = "${local.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = 100 # autoscaling up to 100 GiB
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  parameter_group_name   = aws_db_parameter_group.main.name

  publicly_accessible     = true
  multi_az                = false # single-AZ for MVP cost
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true # MVP — change to false for prod
  deletion_protection = var.deletion_protection
  apply_immediately   = true

  performance_insights_enabled = false # cost saving for MVP

  tags = {
    Name    = "${local.name_prefix}-postgres"
    Project = var.project
    Env     = var.env
  }
}
