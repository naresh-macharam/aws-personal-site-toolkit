variable "domain_name" {
  description = "Primary domain the site will be served on, e.g. \"test.example.com\" or \"example.com\""
  type        = string
}

variable "additional_domain_names" {
  description = "Any extra domains/aliases to serve the same content on, e.g. [\"www.example.com\"]"
  type        = list(string)
  default     = []
}

variable "bucket_name" {
  description = "S3 bucket name. Defaults to domain_name if not set. Must be globally unique."
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for this domain, if DNS is managed in Route53. Leave empty (default) if using an external registrar like Namecheap — in that case, add the printed validation/alias records there manually."
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class. PriceClass_100 = North America + Europe only (cheapest). PriceClass_All = worldwide edge locations."
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags applied to every resource this module creates."
  type        = map(string)
  default     = {}
}
