output "db_secret_arn" {
  description = "ARN of the DB password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_password_plaintext" {
  description = "DB password (sensitive — passed to RDS module)"
  value       = random_password.db.result
  sensitive   = true
}

output "db_username" {
  description = "DB username"
  value       = var.db_username
}

output "app_secret_arn" {
  description = "ARN of the app secrets"
  value       = aws_secretsmanager_secret.app.arn
}
