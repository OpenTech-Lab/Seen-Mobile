terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure for remote state when ready:
  # backend "s3" {
  #   bucket = "spot-terraform-state"
  #   key    = "infra/terraform.tfstate"
  #   region = "ap-northeast-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

# Separate provider for CloudFront resources that require us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

locals {
  bucket_name = "${var.project_name}-media-cdn-${var.environment}"
  lambda_name = "${var.project_name}-media-presign-${var.environment}"
}

# ── S3 Bucket (content-addressed media store) ─────────────────────────────────

resource "aws_s3_bucket" "media" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "media" {
  bucket = aws_s3_bucket.media.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "media" {
  bucket = aws_s3_bucket.media.id
  name   = "auto-tier"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = var.cache_max_age_days
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = var.cache_max_age_days * 2
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    id     = "intelligent-tiering"
    status = "Enabled"

    filter {} # Apply to all objects

    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag", "Content-Length", "Content-Type"]
    max_age_seconds = 86400
  }
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ── CloudFront Origin Access Control ──────────────────────────────────────────

resource "aws_cloudfront_origin_access_control" "media" {
  name                              = "${local.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ── S3 Bucket Policy (CloudFront access only) ────────────────────────────────

resource "aws_s3_bucket_policy" "media" {
  bucket = aws_s3_bucket.media.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.media.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.media.arn
          }
        }
      }
    ]
  })
}

# ── CloudFront Distribution ───────────────────────────────────────────────────

resource "aws_cloudfront_distribution" "media" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Spot media CDN (content-addressed)"
  default_root_object = ""
  price_class         = var.cloudfront_price_class
  http_version        = "http2and3"

  origin {
    domain_name              = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id                = "s3-media"
    origin_access_control_id = aws_cloudfront_origin_access_control.media.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-media"
    compress         = true

    # Content-addressed objects are immutable — cache aggressively
    min_ttl     = 86400    # 1 day minimum
    default_ttl = 31536000 # 365 days
    max_ttl     = 31536000 # 365 days

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # Uncomment when custom domain is configured:
    # acm_certificate_arn      = var.certificate_arn
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1.2_2021"
  }
}

# ── Lambda: Presigned URL Generator ───────────────────────────────────────────

resource "aws_iam_role" "lambda_presign" {
  name = "${local.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_s3_presign" {
  name = "${local.lambda_name}-s3-policy"
  role = aws_iam_role.lambda_presign.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
        ]
        Resource = aws_dynamodb_table.presign_rate_limit.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ]
        Resource = "${aws_s3_bucket.media.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.media.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_dynamodb_table" "presign_rate_limit" {
  name         = "${local.lambda_name}-rate-limit"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "rate_key"

  attribute {
    name = "rate_key"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}

data "archive_file" "lambda_presign" {
  type        = "zip"
  source_dir  = "${path.module}/presign"
  output_path = "${path.module}/.build/presign.zip"
}

resource "aws_lambda_function" "presign" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_presign.arn
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  memory_size   = 128
  timeout       = 5

  # Cap concurrent executions to bound blast radius on a public endpoint.
  # BIP-340 schnorr signature verification is enforced in-handler, but this
  # prevents runaway invocations from exhausting account-level concurrency.
  reserved_concurrent_executions = 20

  filename         = data.archive_file.lambda_presign.output_path
  source_code_hash = data.archive_file.lambda_presign.output_base64sha256

  environment {
    variables = {
      BUCKET_NAME            = aws_s3_bucket.media.id
      RATE_LIMIT_PER_MINUTE  = tostring(var.lambda_rate_limit_per_minute)
      PRESIGN_EXPIRY_SECONDS = "900"
      MAX_UPLOAD_BYTES       = "104857600"
      RATE_LIMIT_TABLE       = aws_dynamodb_table.presign_rate_limit.name
      SUPABASE_URL           = var.supabase_url
      SUPABASE_ANON_KEY      = var.supabase_anon_key
    }
  }
}

resource "aws_lambda_function_url" "presign" {
  function_name = aws_lambda_function.presign.function_name

  # IAM auth is "NONE" because callers are mobile apps (not browsers/AWS services).
  # Security is enforced at the application layer: BIP-340 schnorr signature
  # verification in the Lambda handler. Concurrency is bounded above.
  # If a web client is added, tighten CORS origins below.
  authorization_type = "NONE"

  cors {
    # Mobile-only: CORS is irrelevant for native HTTP clients.
    # Tighten to specific origins before any browser-based client ships.
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["Authorization", "Content-Type"]
    max_age       = 86400
  }
}

resource "aws_cloudwatch_log_group" "lambda_presign" {
  name              = "/aws/lambda/${local.lambda_name}"
  retention_in_days = 14
}
