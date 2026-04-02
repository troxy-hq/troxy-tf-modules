variable "project" { type = string }
variable "env" { type = string }

variable "lambda_invoke_arn" {
  description = "Lambda function invoke ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name (for permission resource)"
  type        = string
}
