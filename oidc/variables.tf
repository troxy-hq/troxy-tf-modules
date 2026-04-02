variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "repos" {
  description = "List of GitHub repos allowed to assume the deploy role (without org prefix)"
  type        = list(string)
}

variable "role_name" {
  description = "Name of the IAM role GitHub Actions will assume"
  type        = string
  default     = "troxy-github-actions-deploy"
}

variable "project" {
  description = "Project tag"
  type        = string
  default     = "troxy"
}

variable "env" {
  description = "Environment tag"
  type        = string
  default     = "mvp"
}
