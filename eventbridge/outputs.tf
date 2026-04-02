output "budget_reset_rule_arn" {
  value = aws_cloudwatch_event_rule.budget_reset.arn
}

output "approval_sweep_rule_arn" {
  value = aws_cloudwatch_event_rule.approval_sweep.arn
}
