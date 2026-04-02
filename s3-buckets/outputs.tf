output "releases_bucket_id" {
  value = aws_s3_bucket.main["releases"].id
}

output "releases_bucket_arn" {
  value = aws_s3_bucket.main["releases"].arn
}

output "releases_bucket_regional_domain_name" {
  value = aws_s3_bucket.main["releases"].bucket_regional_domain_name
}

output "install_bucket_id" {
  value = aws_s3_bucket.main["install"].id
}

output "install_bucket_regional_domain_name" {
  value = aws_s3_bucket.main["install"].bucket_regional_domain_name
}

output "events_bucket_id" {
  value = aws_s3_bucket.main["events"].id
}

output "events_bucket_arn" {
  value = aws_s3_bucket.main["events"].arn
}
