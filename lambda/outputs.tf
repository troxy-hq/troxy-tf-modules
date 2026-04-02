output "function_arn" {
  value = aws_lambda_function.core_handler.arn
}

output "function_name" {
  value = aws_lambda_function.core_handler.function_name
}

output "invoke_arn" {
  description = "ARN for invoking the function (used by API Gateway)"
  value       = aws_lambda_function.core_handler.invoke_arn
}

output "role_arn" {
  value = aws_iam_role.lambda.arn
}

output "role_name" {
  value = aws_iam_role.lambda.name
}
