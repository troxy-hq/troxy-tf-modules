variable "project" { type = string }
variable "env" { type = string }

variable "releases_bucket_regional_domain_name" {
  description = "Releases S3 bucket regional domain name"
  type        = string
}

variable "install_bucket_regional_domain_name" {
  description = "Install script S3 bucket regional domain name"
  type        = string
}
