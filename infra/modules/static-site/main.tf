locals {
  bucket_name  = var.bucket_name != "" ? var.bucket_name : var.domain_name
  all_domains  = concat([var.domain_name], var.additional_domain_names)
  manage_dns   = var.route53_zone_id != ""
}

# ---------------------------------------------------------------------------
# S3 bucket — private, only readable by CloudFront via Origin Access Control
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.s3_oac_read.json
}

data "aws_iam_policy_document" "s3_oac_read" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

# ---------------------------------------------------------------------------
# ACM certificate — MUST be created in us-east-1 for CloudFront, regardless
# of which region everything else lives in. Pass the aws.us_east_1 provider
# alias in from the caller (see environments/test/main.tf).
# ---------------------------------------------------------------------------

resource "aws_acm_certificate" "site" {
  provider                 = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = var.additional_domain_names
  validation_method          = "DNS"
  tags                        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# If DNS is in Route53, validate automatically.
resource "aws_route53_record" "cert_validation" {
  for_each = local.manage_dns ? {
    for dvo in aws_acm_certificate.site.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id = var.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "site" {
  count                   = local.manage_dns ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# If DNS is in Route53, also point the actual domain(s) at CloudFront
# automatically — an ALIAS record, not a CNAME, since ALIAS works at
# the zone apex and resolves without an extra DNS hop.
resource "aws_route53_record" "site_alias" {
  for_each = local.manage_dns ? toset(local.all_domains) : toset([])

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

# ---------------------------------------------------------------------------
# CloudFront Function — appends index.html to folder-style URIs so that
# both the site root and nested paths like /blog/ or /blog/posts/foo/
# resolve correctly against the S3 REST origin (which does not support
# S3's own "index document" behavior the way the website-hosting endpoint
# does).
# ---------------------------------------------------------------------------

resource "aws_cloudfront_function" "append_index" {
  name    = "${replace(var.domain_name, ".", "-")}-append-index-html"
  runtime = "cloudfront-js-2.0"
  comment = "Appends index.html to folder-style request URIs"
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      if (uri.endsWith('/')) {
        request.uri += 'index.html';
      } else if (!uri.includes('.')) {
        request.uri += '/index.html';
      }
      return request;
    }
  EOT
}

# ---------------------------------------------------------------------------
# CloudFront distribution
# ---------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${local.bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class
  aliases             = local.all_domains
  tags                = var.tags

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-${local.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods          = ["GET", "HEAD"]
    target_origin_id        = "s3-${local.bucket_name}"
    viewer_protocol_policy  = "redirect-to-https"
    compress                = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS managed "CachingOptimized"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.append_index.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.site.arn
    ssl_support_method        = "sni-only"
    minimum_protocol_version  = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.site]
}
