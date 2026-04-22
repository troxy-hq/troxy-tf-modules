# troxy-tf-modules

Reusable Terraform modules for Troxy infrastructure.  
Used by [troxy-tf-live](https://github.com/troxy-hq/troxy-tf-live) via `ref=main`.

## Modules

| Module | Description |
|--------|-------------|
| `lambda/` | Lambda function — IAM role, log group, env vars, Secrets Manager access |
| `api-gateway/` | HTTP API Gateway v2 — Lambda integration, CORS, access logging, stage |
| `networking/` | VPC, public + secondary subnets, internet gateway, route tables, security groups |

## Usage

Referenced from terragrunt.hcl files in troxy-tf-live:

```hcl
terraform {
  source = "git::https://github.com/troxy-hq/troxy-tf-modules.git//lambda?ref=main"
}
```

## Notes

- All modules use `ref=main` — changes here take effect on the next `terragrunt apply` in troxy-tf-live
- CORS allowed origins are configured in `api-gateway/main.tf`
- Networking uses "secondary" subnets (not truly private — have IGW route for RDS connectivity at MVP)
