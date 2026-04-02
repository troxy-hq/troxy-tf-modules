variable "project" {
  type = string
}

variable "env" {
  type = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for the Redis subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for ElastiCache"
  type        = list(string)
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}
