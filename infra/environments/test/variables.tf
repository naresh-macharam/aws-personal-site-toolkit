variable "aws_region" {
  description = "Default AWS region for non-CloudFront resources"
  type        = string
  default     = "eu-west-2"
}

variable "test_domain" {
  description = "A throwaway subdomain to prove the module works, e.g. \"tftest.nareshmacharam.com\". Do NOT use your live domain here."
  type        = string
}

variable "route53_zone_id" {
  description = "Leave blank if using Namecheap for DNS — you'll add the validation record manually and re-run apply"
  type        = string
  default     = ""
}

variable "github_org" {
  description = "Your GitHub username, e.g. \"naresh852\""
  type        = string
}

variable "github_repo" {
  description = "The throwaway repo that will deploy to this test site, e.g. \"test-site-deploy\""
  type        = string
}

variable "blog_github_repo" {
  description = "A second throwaway repo for testing the Hugo blog deploy, e.g. \"test-blog-deploy\""
  type        = string
}

variable "contact_recipient_email" {
  description = "Where you want to receive test contact/comment submissions"
  type        = string
}

variable "contact_sender_email" {
  description = "The \"from\" address for the contact pipeline — can be the same as recipient"
  type        = string
}
