variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "spot"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "cache_max_age_days" {
  description = "Days before S3 objects transition to cheaper storage if not accessed"
  type        = number
  default     = 90
}

variable "cloudfront_price_class" {
  description = "CloudFront price class. PriceClass_100 = NA+EU (cheapest)"
  type        = string
  default     = "PriceClass_100"
}

variable "lambda_rate_limit_per_minute" {
  description = "Maximum presign requests per pubkey per minute"
  type        = number
  default     = 10
}

variable "supabase_url" {
  description = "Supabase project URL used to validate upload sessions"
  type        = string
}

variable "supabase_anon_key" {
  description = "Public Supabase anon key used when validating upload sessions"
  type        = string
  sensitive   = true
}
