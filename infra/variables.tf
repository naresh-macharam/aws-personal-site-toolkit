# ---------------------------------------------------------------------------
# The ~8 values you actually need to set. Everything else has a sensible
# default. Copy terraform.tfvars.example to terraform.tfvars and fill these
# in.
# ---------------------------------------------------------------------------

variable "domain_name" {
  description = "Your real domain, e.g. \"example.com\""
  type        = string
}

variable "include_www" {
  description = "If true, also serves and allows CORS for www.<domain_name>"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID, if your DNS is on Route53. Leave \"\" for Namecheap or any other external registrar — see the README for the one manual step that requires."
  type        = string
  default     = ""
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "github_org" {
  description = "Your GitHub username or org"
  type        = string
}

variable "homepage_repo" {
  description = "Repo name (no org prefix) containing your static homepage"
  type        = string
}

variable "blog_repo" {
  description = "Repo name (no org prefix) containing your Hugo blog"
  type        = string
}

variable "github_owner_id" {
  description = <<-EOT
    Your numeric GitHub user/org ID. Required if either repo was
    created on or after July 15, 2026 (GitHub's "immutable subject
    claims" rollout) — which is true for essentially any new repo at
    this point. Leave null ONLY if you're certain both repos predate
    that change and have not opted into the new format.

    Find it: gh api users/<your-username> --jq .id
    Or visit https://api.github.com/users/<your-username> and read
    the "id" field.
  EOT
  type    = string
  default = null
}

variable "homepage_repo_id" {
  description = "Numeric ID of your homepage repo. Find it: gh api repos/<org>/<repo> --jq .id — or visit https://api.github.com/repos/<org>/<repo> and read the \"id\" field."
  type        = string
  default     = null
}

variable "blog_repo_id" {
  description = "Numeric ID of your blog repo. Same lookup method as homepage_repo_id, pointed at your blog repo instead."
  type        = string
  default     = null
}

variable "toolkit_repo" {
  description = <<-EOT
    org/repo of wherever YOU published this toolkit (e.g. after
    forking it on GitHub) — e.g. "naresh852/aws-personal-site-toolkit".
    The generated deploy workflows reference this repo's reusable
    workflows via `uses:`, so a fix pushed here reaches every
    generated pipeline automatically, without re-copying files.
  EOT
  type = string
}

variable "toolkit_ref" {
  description = "Branch or tag of toolkit_repo to pin the reusable workflows to. \"main\" tracks latest; a tag (e.g. \"v1.0.0\") pins to a stable point and won't change under you."
  type        = string
  default     = "main"
}

variable "contact_recipient_email" {
  description = "Where contact form + blog comment submissions should be emailed"
  type        = string
}

variable "contact_sender_email" {
  description = "The \"from\" address — can be the same as recipient. You'll need to click one SES verification email after applying; unavoidable, see README."
  type        = string
}

# ---------------------------------------------------------------------------
# Everything below has a working default — only change these if you want to.
# ---------------------------------------------------------------------------

variable "create_oidc_provider" {
  description = "false if a GitHub OIDC provider already exists in this AWS account (common if you've set up any other GitHub Actions + AWS pipeline before)"
  type        = bool
  default     = true
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "site_title" {
  description = "Used in <title> tags and the blog's header logo text"
  type        = string
  default     = "My Site"
}

variable "site_description" {
  type    = string
  default = "Notes on what I build and what I learn along the way."
}

variable "blog_headline" {
  type    = string
  default = "Notes and write-ups."
}

variable "blog_subhead" {
  type    = string
  default = "Thoughts on what I build and what I learn along the way."
}

variable "colors" {
  description = "Override any subset of the default brand palette"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type = map(string)
  default = {
    Project   = "aws-personal-site-toolkit"
    ManagedBy = "terraform"
  }
}
