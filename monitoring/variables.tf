variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "alert_email" {
  type        = string
  description = "Email address for all ops alerts"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the core Lambda function"
}

variable "rds_instance_id" {
  type        = string
  description = "RDS instance identifier"
}

variable "api_gateway_id" {
  type        = string
  description = "API Gateway ID (HTTP API)"
}

variable "lambda_error_threshold" {
  type        = number
  default     = 5
  description = "Number of Lambda errors in 5 min to trigger alarm"
}

variable "rds_cpu_threshold" {
  type        = number
  default     = 80
  description = "RDS CPU % threshold"
}

variable "rds_storage_threshold_gb" {
  type        = number
  default     = 2
  description = "RDS free storage alarm threshold (GB)"
}
