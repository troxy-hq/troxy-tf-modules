# ─────────────────────────────────────────────
# S3 — Terraform Remote State Bucket
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "tf_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────
# IAM Identity Center
# ─────────────────────────────────────────────
data "aws_ssoadmin_instances" "main" {}

# We import the instance — Identity Center instances cannot be created
# via Terraform, only referenced. This resource is a marker so the
# instance ARN lives in state and downstream modules can use it.
resource "aws_ssoadmin_instance_access_control_attributes" "main" {
  instance_arn = tolist(data.aws_ssoadmin_instances.main.arns)[0]

  attribute {
    key = "email"
    value {
      source = ["$${path:email}"]
    }
  }
}
