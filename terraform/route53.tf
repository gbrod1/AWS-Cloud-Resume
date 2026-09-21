# Route 53 hosted zone for the domain.
resource "aws_route53_zone" "resume_website" {
  name = "gloriabrodrick.com"
}

# Root domain - IPv4
resource "aws_route53_record" "resume_website_ipv4" {
  zone_id = aws_route53_zone.resume_website.zone_id
  name    = "gloriabrodrick.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# Root domain - IPv6
resource "aws_route53_record" "resume_website_ipv6" {
  zone_id = aws_route53_zone.resume_website.zone_id
  name    = "gloriabrodrick.com"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# www domain - IPv4
resource "aws_route53_record" "resume_website_www_ipv4" {
  zone_id = aws_route53_zone.resume_website.zone_id
  name    = "www.gloriabrodrick.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

# www domain - IPv6
resource "aws_route53_record" "resume_website_www_ipv6" {
  zone_id = aws_route53_zone.resume_website.zone_id
  name    = "www.gloriabrodrick.com"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}