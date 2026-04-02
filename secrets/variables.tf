variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "troxy"
}

variable "ses_from_email" {
  description = "From email address for SES"
  type        = string
  default     = ""
}
