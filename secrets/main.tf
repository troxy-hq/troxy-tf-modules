locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# Random Passwords
# ─────────────────────────────────────────────
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"

  lifecycle {
    ignore_changes = [result]
  }
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false

  lifecycle {
    ignore_changes = [result]
  }
}

resource "random_password" "api_key_salt" {
  length  = 32
  special = false

  lifecycle {
    ignore_changes = [result]
  }
}

# ─────────────────────────────────────────────
# DB Password Secret
# ─────────────────────────────────────────────
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${local.name_prefix}/db/password"
  description             = "Troxy RDS PostgreSQL password"
  recovery_window_in_days = 0 # Immediately deletable in MVP

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db.result
}

# ─────────────────────────────────────────────
# App Secrets (JWT, API key salt, from email)
# ─────────────────────────────────────────────
resource "aws_secretsmanager_secret" "app" {
  name                    = "${local.name_prefix}/app"
  description             = "Troxy application secrets"
  recovery_window_in_days = 0

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_secretsmanager_secret_version" "app" {
  secret_id = aws_secretsmanager_secret.app.id
  secret_string = jsonencode({
    jwt_secret     = random_password.jwt_secret.result
    api_key_salt   = random_password.api_key_salt.result
    ses_from_email = var.ses_from_email
  })
}
