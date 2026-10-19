output "bucket_name" {
  description = "Name of the S3 bucket holding the site content"
  value       = aws_s3_bucket.site.id
}

output "bucket_arn" {
  value = aws_s3_bucket.site.arn
}

output "cloudfront_distribution_id" {
  description = "Pass this to your GitHub Actions workflow for cache invalidation"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_arn" {
  description = "Needed when writing the IAM policy that allows GitHub Actions to invalidate this distribution"
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront_domain_name" {
  description = "The *.cloudfront.net domain — point your registrar's CNAME/ALIAS record here if not using Route53"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.site.arn
}

output "acm_validation_records" {
  description = <<-EOT
    If route53_zone_id was NOT set, add these CNAME records at your registrar
    (e.g. Namecheap) BEFORE the CloudFront distribution can finish creating.
    Terraform will otherwise hang or fail waiting on certificate validation.
  EOT
  value = {
    for dvo in aws_acm_certificate.site.domain_validation_options :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }
}

output "dns_auto_configured" {
  description = "true if this module created the domain -> CloudFront record automatically (Route53 only). If false, manually create a CNAME (or your registrar's equivalent) pointing at cloudfront_domain_name."
  value       = var.route53_zone_id != ""
}
