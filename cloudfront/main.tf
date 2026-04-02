locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# Releases + Install Distribution (public buckets)
# ─────────────────────────────────────────────
resource "aws_cloudfront_distribution" "releases" {
  enabled     = true
  comment     = "Troxy ${var.env} releases + install"
  price_class = "PriceClass_100"

  origin {
    domain_name = var.releases_bucket_regional_domain_name
    origin_id   = "releases-s3"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    domain_name = var.install_bucket_regional_domain_name
    origin_id   = "install-s3"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "releases-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 604800
  }

  ordered_cache_behavior {
    path_pattern           = "/install*"
    target_origin_id       = "install-s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    min_ttl     = 0
    default_ttl = 300 # short TTL for install script (updates quickly)
    max_ttl     = 3600
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}
