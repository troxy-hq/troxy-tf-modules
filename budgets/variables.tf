variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "monthly_limit" {
  type    = number
  default = 100
}

variable "alert_threshold" {
  type    = number
  default = 80
}
