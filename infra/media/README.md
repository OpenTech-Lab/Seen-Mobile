# Spot Media CDN Infrastructure

Terraform-managed AWS resources for the CDN media acceleration layer.

```
S3 (content-addressed store)
  └─ CloudFront (global CDN, 365-day cache)
Lambda (Supabase account + BIP-340 wallet proof, durable quotas)
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2
- [Node.js](https://nodejs.org/) >= 22 (for Lambda dependencies)
- AWS credentials configured (`aws configure` or environment variables)

## Quick Start

```bash
# 1. Install Lambda dependencies
cd presign
npm install
cd ../..

# 2. Initialize Terraform
terraform init

# 3. Preview changes
terraform plan \
  -var="supabase_url=https://your-project.supabase.co" \
  -var="supabase_anon_key=$SUPABASE_ANON_KEY"

# 4. Deploy
terraform apply
```

After `terraform apply` completes, note the outputs:

```
cloudfront_domain        = "d3ttkxcceqn0cp.cloudfront.net"
lambda_presign_url       = "https://xyz.lambda-url.ap-northeast-1.on.aws/"
s3_bucket_name           = "spot-media-cdn-prod"
cloudfront_distribution_id = "E1GYAIP2KQIFMN"
```

You can also retrieve them later:

```bash
terraform output
```

## Connect to the Mobile App

Pass the Terraform outputs as compile-time constants via `--dart-define`:

```bash
cd ../mobile
flutter run \
  --dart-define=CDN_BASE_URL=https://$(cd ../infra && terraform output -raw cloudfront_domain) \
  --dart-define=CDN_PRESIGN_URL=$(cd ../infra && terraform output -raw lambda_presign_url)
```

For release builds:

```bash
flutter build apk \
  --dart-define=CDN_BASE_URL=https://<cloudfront_domain> \
  --dart-define=CDN_PRESIGN_URL=<lambda_presign_url>
```

## GitHub Actions Setup

Add these repository secrets (Settings > Secrets and variables > Actions):

| Secret | Value | Example |
|--------|-------|---------|
| `CDN_BASE_URL` | `https://<cloudfront_domain>` | `https://d3ttkxcceqn0cp.cloudfront.net` |
| `CDN_PRESIGN_URL` | `<lambda_presign_url>` | `https://xyz.lambda-url.ap-northeast-1.on.aws/` |

Then in your workflow:

```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=CDN_BASE_URL=${{ secrets.CDN_BASE_URL }} \
      --dart-define=CDN_PRESIGN_URL=${{ secrets.CDN_PRESIGN_URL }}
```

If no `--dart-define` values are provided, CDN is automatically disabled and the app falls back to P2P-only transport.

## Configuration

Edit `variables.tf` or pass `-var` flags to customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `ap-northeast-1` | AWS region |
| `environment` | `prod` | Environment name (`dev`, `staging`, `prod`) |
| `cloudfront_price_class` | `PriceClass_100` | `PriceClass_100` = NA+EU (cheapest), `PriceClass_200` = +Asia, `PriceClass_All` = global |
| `cache_max_age_days` | `90` | Days before S3 objects move to archive tier |
| `lambda_rate_limit_per_minute` | `10` | Durable max presign requests per account/IP per minute |
| `supabase_url` | required | Supabase project URL used to validate access tokens |
| `supabase_anon_key` | required, sensitive | Public anon key used with the caller's access token |

Example with overrides:

```bash
terraform apply \
  -var="environment=staging" \
  -var="cloudfront_price_class=PriceClass_200" \
  -var="cache_max_age_days=60"
```

## Architecture

### S3 Bucket (`spot-media-cdn-<env>`)
- Objects keyed by SHA-256 content hash (content-addressed, naturally deduplicating)
- S3 Intelligent-Tiering (auto-moves cold objects to cheaper storage)
- Server-side AES-256 encryption
- Not publicly accessible — CloudFront only via Origin Access Control

### CloudFront Distribution
- 365-day cache TTL (content-addressed objects are immutable)
- HTTP/2 + HTTP/3 enabled
- HTTPS only (redirect HTTP)
- Gzip/Brotli compression

### Lambda Presign Function (`spot-media-presign-<env>`)
- Generates presigned S3 PUT URLs for direct mobile-to-S3 uploads
- Auth: BIP-340 schnorr signature verification (client signs `PUT:<hash>:<timestamp>`)
- Rate limited: configurable per pubkey per minute
- Reserved concurrency: 20 (bounds blast radius)
- Runtime: Node.js 22.x, 128 MB, 5s timeout

### Request Flow

```
Upload:
  Mobile → Lambda (get presigned URL) → S3 (direct PUT)

Fetch:
  Mobile → CloudFront → S3
```

## Custom Domain (Optional)

To use a custom domain (e.g., `cdn.spot.app`):

1. Request an ACM certificate in `us-east-1` for your domain
2. Uncomment the `viewer_certificate` block in `main.tf`
3. Add a CNAME record pointing your domain to the CloudFront distribution domain
4. Update `CDN_BASE_URL` to use your custom domain

## Teardown

```bash
# Empty the S3 bucket first (required before deletion)
aws s3 rm s3://spot-media-cdn-prod --recursive

# Destroy all resources
terraform destroy
```

## Cost Estimate

| DAU | S3 Storage | CloudFront Transfer | Lambda | Total |
|-----|-----------|---------------------|--------|-------|
| 100 | ~$0.10 | ~$4 | ~$0.01 | ~$4/mo |
| 1,000 | ~$1 | ~$38 | ~$0.02 | ~$39/mo |
| 10,000 | ~$10 | ~$380 | ~$0.20 | ~$390/mo |

Assumes 3 posts/user/day, 500 KB avg, 10x read amplification.
