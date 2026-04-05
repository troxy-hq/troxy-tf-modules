output "ops_topic_arn" {
  description = "ARN of the ops alerts SNS topic"
  value       = aws_sns_topic.ops.arn
}

output "ops_topic_name" {
  description = "Name of the ops alerts SNS topic"
  value       = aws_sns_topic.ops.name
}
