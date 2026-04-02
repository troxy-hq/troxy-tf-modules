locals {
  name_prefix = "${var.project}-${var.env}"
}

resource "aws_sns_topic" "notifications" {
  name = "${local.name_prefix}-notifications"

  tags = {
    Project = var.project
    Env     = var.env
  }
}
