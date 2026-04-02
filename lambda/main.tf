locals {
  name_prefix   = "${var.project}-${var.env}"
  function_name = "${local.name_prefix}-core-handler"
}

# ─────────────────────────────────────────────
# Placeholder Lambda handler (Python)
# Replace via separate app CI/CD pipeline
# ─────────────────────────────────────────────
data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = <<-PYTHON
import json, os

def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({
            "status": "ok",
            "service": "troxy-core-handler",
            "env": os.environ.get("ENV", "unknown"),
            "version": "placeholder-0.0.1"
        })
    }
PYTHON
    filename = "handler.py"
  }
}

# ─────────────────────────────────────────────
# IAM Role
# ─────────────────────────────────────────────
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.function_name}-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# Managed policies
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom policy for Troxy services
data "aws_iam_policy_document" "lambda_permissions" {
  # Secrets Manager — read secrets at runtime
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.db_secret_arn, var.app_secret_arn]
  }

  # SNS — send approval notifications
  statement {
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [var.sns_topic_arn]
  }

  # SES — send approval emails
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }

  # S3 — write audit events archive
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["arn:aws:s3:::${var.events_bucket}/*"]
  }

  # CloudWatch Logs — beyond what VPCAccessExecutionRole provides
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/aws/lambda/${local.function_name}*"]
  }

  # EventBridge — publish events
  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_permissions" {
  name   = "${local.function_name}-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

# ─────────────────────────────────────────────
# CloudWatch Log Group
# ─────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = 14

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# ─────────────────────────────────────────────
# Lambda Function
# ─────────────────────────────────────────────
resource "aws_lambda_function" "core_handler" {
  function_name = local.function_name
  description   = "Troxy core handler — policy evaluation, approvals, audit"

  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  runtime          = "python3.12"
  handler          = "handler.handler"
  role             = aws_iam_role.lambda.arn

  memory_size = var.memory_size
  timeout     = var.timeout

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      ENV            = var.env
      DB_HOST        = var.db_host
      DB_PORT        = tostring(var.db_port)
      DB_NAME        = var.db_name
      DB_USER        = var.db_username
      DB_SECRET_ARN  = var.db_secret_arn
      APP_SECRET_ARN = var.app_secret_arn
      SNS_TOPIC_ARN  = var.sns_topic_arn
      EVENTS_BUCKET  = var.events_bucket
    }
  }

  lifecycle {
    # App code deploys separately — Terraform only manages infra config
    ignore_changes = [filename, source_code_hash]
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.vpc_access,
    aws_iam_role_policy.lambda_permissions,
  ]

  tags = {
    Project = var.project
    Env     = var.env
  }
}
