variable "project" { type = string }
variable "env" { type = string }

variable "domain" {
  description = "Domain to verify in SES (e.g. troxy.ai)"
  type        = string
}

variable "from_email" {
  description = "From email address"
  type        = string
  default     = ""
}
