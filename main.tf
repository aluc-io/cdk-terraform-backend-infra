variable "BUCKET_NAME" {
}

variable "BUCKET_NAME_FOR_LOG" {
}

variable "ROUTE53_ZONE_NAME" {
}

variable "DOMAIN" {
}

locals {
  s3_origin_id            = terraform.workspace
  route53_zone_name       = var.ROUTE53_ZONE_NAME
  bucket_name             = var.BUCKET_NAME
  bucket_name_for_log     = var.BUCKET_NAME_FOR_LOG
  base_domain             = var.DOMAIN
  domain = local.s3_origin_id == "default" ? local.base_domain : "${local.s3_origin_id}.${local.base_domain}"
}

data "aws_region" "current" {
}

terraform {
  required_version = ">= 0.12"
  backend "s3" {
  }
}

provider "aws" {
  version = "~> 2.0"
}

data "aws_route53_zone" "main" {
  name         = local.route53_zone_name
  private_zone = false
}


resource "aws_s3_bucket" "website" {
  bucket = local.bucket_name
  acl    = "private"
  tags = {
    Name = "${local.base_domain} static website"
  }
}
resource "aws_s3_bucket_policy" "default" {
  bucket = aws_s3_bucket.website.id
  policy = <<EOF
{
"Version": "2008-10-17",
"Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "${aws_cloudfront_origin_access_identity.website.iam_arn}"
        },
        "Action": "s3:*",
        "Resource": "${aws_s3_bucket.website.arn}/*"
    }
  ]
}
EOF
}

resource "aws_cloudfront_origin_access_identity" "website" {
  comment = "for website access"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    origin_path = "/${local.domain}"
    s3_origin_config {
      origin_access_identity   = aws_cloudfront_origin_access_identity.website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.website.id}.s3.amazonaws.com"
    prefix          = "log-cloudfront"
  }

  aliases = [local.s3_origin_id == "default" ? local.base_domain : "${local.s3_origin_id}.${local.base_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 30
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = local.s3_origin_id
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.main.certificate_arn
    ssl_support_method             = "sni-only"
  }
}

resource "aws_acm_certificate" "main" {
  domain_name       = local.base_domain
  validation_method = "DNS"
}
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.main.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.main.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.main.id
  records = [aws_acm_certificate.main.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = local.bucket_name_for_log
  acl    = "log-delivery-write"
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = true
  }
}
