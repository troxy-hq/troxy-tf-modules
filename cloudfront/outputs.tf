output "releases_distribution_id" {
  value = aws_cloudfront_distribution.releases.id
}

output "releases_domain_name" {
  description = "CloudFront domain for releases + install script"
  value       = aws_cloudfront_distribution.releases.domain_name
}
