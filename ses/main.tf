locals {
  name_prefix = "${var.project}-${var.env}"
}

# ─────────────────────────────────────────────
# SES Domain Identity
# ─────────────────────────────────────────────
resource "aws_ses_domain_identity" "main" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# ─────────────────────────────────────────────
# SES Configuration Set
# ─────────────────────────────────────────────
resource "aws_ses_configuration_set" "main" {
  name = "${local.name_prefix}-config"

  delivery_options {
    tls_policy = "Require"
  }
}

# ─────────────────────────────────────────────
# Email Identity (from address)
# Requires manual verification if not on verified domain
# ─────────────────────────────────────────────
resource "aws_ses_email_identity" "from" {
  count = var.from_email != "" ? 1 : 0
  email = var.from_email
}
