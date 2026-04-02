output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform remote state"
  value       = aws_s3_bucket.tf_state.arn
}

output "sso_instance_arn" {
  description = "IAM Identity Center instance ARN"
  value       = tolist(data.aws_ssoadmin_instances.main.arns)[0]
}

output "sso_identity_store_id" {
  description = "IAM Identity Center identity store ID"
  value       = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
}
