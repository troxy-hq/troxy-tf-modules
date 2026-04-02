locals {
  name_prefix = "${var.project}-${var.env}"

  buckets = {
    releases = {
      name   = "${local.name_prefix}-releases"
      public = true
    }
    install = {
      name   = "${local.name_prefix}-install"
      public = true
    }
    dashboard = {
      name   = "${local.name_prefix}-dashboard"
      public = false
    }
    events = {
      name   = "${local.name_prefix}-events"
      public = false
    }
  }
}

# ─────────────────────────────────────────────
# S3 Buckets
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "main" {
  for_each = local.buckets

  bucket = each.value.name

  tags = {
    Name    = each.value.name
    Project = var.project
    Env     = var.env
    Purpose = each.key
  }
}

resource "aws_s3_bucket_versioning" "main" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access on private buckets; allow on public buckets
resource "aws_s3_bucket_public_access_block" "main" {
  for_each = local.buckets
  bucket   = aws_s3_bucket.main[each.key].id

  block_public_acls       = !each.value.public
  block_public_policy     = !each.value.public
  ignore_public_acls      = !each.value.public
  restrict_public_buckets = !each.value.public
}

# Public read policy for releases and install buckets
resource "aws_s3_bucket_policy" "public_read" {
  for_each = { for k, v in local.buckets : k => v if v.public }
  bucket   = aws_s3_bucket.main[each.key].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicRead"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.main[each.key].arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.main]
}

# CORS for releases and install buckets (binary downloads)
resource "aws_s3_bucket_cors_configuration" "public" {
  for_each = { for k, v in local.buckets : k => v if v.public }
  bucket   = aws_s3_bucket.main[each.key].id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3600
  }
}
