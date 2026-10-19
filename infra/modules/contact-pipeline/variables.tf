variable "name_prefix" {
  description = "Prefix for all resource names, e.g. \"personal-site\" -> \"personal-site-contact-handler\""
  type        = string
}

variable "recipient_email" {
  description = "Where you want to receive messages"
  type        = string
}

variable "sender_email" {
  description = "The \"from\" address. Must be SES-verified — this module verifies it for you, but you still need to click the confirmation link AWS emails you (unavoidable without domain-level SES verification, a stretch goal for later)."
  type        = string
}

variable "allowed_origins" {
  description = "List of origins allowed to call this endpoint, e.g. [\"https://www.example.com\", \"https://example.com\"]. Include every variant (www/non-www) your site is actually served from."
  type        = list(string)
}

variable "aws_region" {
  description = "Region SES sends from — must match a region where you've verified the sender identity"
  type        = string
  default     = "eu-west-2"
}

variable "verify_recipient_separately" {
  description = "Set true if recipient_email differs from sender_email and also needs SES verification (SES sandbox mode requires both sender and recipient to be verified)"
  type        = bool
  default     = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
