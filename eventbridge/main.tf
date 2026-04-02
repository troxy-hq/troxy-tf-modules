locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# Budget Reset — midnight UTC on the 1st of every month
# ─────────────────────────────────────────────
resource "aws_cloudwatch_event_rule" "budget_reset" {
  name                = "${local.name_prefix}-budget-reset"
  description         = "Reset all monthly budget envelopes"
  schedule_expression = "cron(0 0 1 * ? *)"

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_cloudwatch_event_target" "budget_reset" {
  rule      = aws_cloudwatch_event_rule.budget_reset.name
  target_id = "core-handler"
  arn       = var.lambda_arn

  input = jsonencode({ type = "budget_reset" })
}

resource "aws_lambda_permission" "budget_reset" {
  statement_id  = "AllowEventBridgeBudgetReset"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.budget_reset.arn
}

# ─────────────────────────────────────────────
# Approval Timeout — sweep expired pending approvals every 5 minutes
# ─────────────────────────────────────────────
resource "aws_cloudwatch_event_rule" "approval_sweep" {
  name                = "${local.name_prefix}-approval-sweep"
  description         = "Expire pending approvals that have timed out"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Project = var.project
    Env     = var.env
  }
}

resource "aws_cloudwatch_event_target" "approval_sweep" {
  rule      = aws_cloudwatch_event_rule.approval_sweep.name
  target_id = "core-handler"
  arn       = var.lambda_arn

  input = jsonencode({ type = "approval_sweep" })
}

resource "aws_lambda_permission" "approval_sweep" {
  statement_id  = "AllowEventBridgeApprovalSweep"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.approval_sweep.arn
}
