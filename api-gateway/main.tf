locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# HTTP API (v2) — low latency, cost-effective
# ─────────────────────────────────────────────
resource "aws_apigatewayv2_api" "main" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"
  description   = "Troxy ${var.env} core API"

  cors_configuration {
    allow_credentials = false
    allow_headers     = ["authorization", "content-type", "x-troxy-key"]
    allow_methods     = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
    allow_origins     = ["https://dash.troxy.io", "https://troxy.io", "http://localhost:3000"]
    max_age           = 3600
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# ─────────────────────────────────────────────
# Lambda Integration
# ─────────────────────────────────────────────
resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_invoke_arn

  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Catch-all route — Lambda handles routing internally
resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# ─────────────────────────────────────────────
# Stage — auto-deploy on config change
# ─────────────────────────────────────────────
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/${local.name_prefix}-api"
  retention_in_days = 14

  tags = {
    Project = var.project
    Env     = var.env
  }
}

# ─────────────────────────────────────────────
# Permission — allow API Gateway to invoke Lambda
# ─────────────────────────────────────────────
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
