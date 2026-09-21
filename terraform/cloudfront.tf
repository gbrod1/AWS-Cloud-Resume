# Allow CloudFront to read objects from our private S3 bucket.
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.resume_website.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

# Give CloudFront permission to read from the private S3 bucket.
resource "aws_s3_bucket_policy" "resume_website" {
  bucket = aws_s3_bucket.resume_website.id
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

# Name used to identify the S3 origin inside CloudFront.
locals {
  s3_origin_id = "resume-website-s3-origin"
}

# CloudFront Origin Access Control.
resource "aws_cloudfront_origin_access_control" "resume_website" {
  name                              = "resume-website-oac"
  description                       = "OAC for the private resume website S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront distribution.
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = "CloudFront distribution for my resume website"

  # Custom domains for the website.
  aliases = [
    "gloriabrodrick.com",
    "www.gloriabrodrick.com"
  ]

  # S3 origin.
  origin {
    domain_name              = aws_s3_bucket.resume_website.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.resume_website.id
  }

  # Default behaviour for visitors.
  default_cache_behavior {
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = [
      "GET",
      "HEAD"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Allow visitors from anywhere in the world.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use our ACM certificate for HTTPS.
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.resume_website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}