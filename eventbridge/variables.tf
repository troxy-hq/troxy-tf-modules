variable "project" { type = string }
variable "env" { type = string }

variable "lambda_arn" {
  description = "Core handler Lambda ARN"
  type        = string
}

variable "lambda_function_name" {
  description = "Core handler Lambda function name"
  type        = string
}
