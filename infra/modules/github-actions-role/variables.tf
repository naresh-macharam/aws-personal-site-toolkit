variable "oidc_provider_arn" {
  description = "Output from the github-oidc-provider module"
  type        = string
}

variable "github_org" {
  description = "GitHub username or organization, e.g. \"naresh852\""
  type        = string
}

variable "github_repo" {
  description = "Repository name only, no org prefix, e.g. \"personal-website\""
  type        = string
}

variable "github_owner_id" {
  description = <<-EOT
    Numeric GitHub user/org ID. REQUIRED for any repo created on or
    after July 15, 2026 (GitHub's "immutable subject claims" rollout),
    since those repos' OIDC tokens embed this ID in the sub claim and
    a plain username-based trust policy will never match, failing
    with AssumeRoleWithWebIdentity errors no matter how correct the
    org/repo names are.

    Find it with: gh api users/<your-username> --jq .id
    Or without the CLI: https://api.github.com/users/<your-username>
    (look for the "id" field)

    Leave null (default) only for repos created before that date that
    have NOT opted into the new format — this module then falls back
    to the legacy repo:org/repo pattern.
  EOT
  type    = string
  default = null
}

variable "github_repo_id" {
  description = <<-EOT
    Numeric GitHub repository ID. Required alongside github_owner_id
    — see that variable's description. Find it with:
    gh api repos/<owner>/<repo> --jq .id
    Or without the CLI: https://api.github.com/repos/<owner>/<repo>
    (look for the "id" field)
  EOT
  type    = string
  default = null
}

variable "allowed_ref" {
  description = <<-EOT
    Controls how strictly the trust policy matches. Default "*" means any
    branch, tag, or PR from this repo can assume the role — simplest, and
    since the role is already scoped to exactly one repo you control, this
    is a reasonable default for a personal project. Tighten it if you want,
    e.g. "ref:refs/heads/main" to only allow pushes to main.
  EOT
  type    = string
  default = "*"
}

variable "role_name" {
  description = "Name for the IAM role, e.g. \"github-actions-homepage-deploy\""
  type        = string
}

variable "policy_json" {
  description = "IAM policy document (as JSON string) defining exactly what this role can do. Build this with a data \"aws_iam_policy_document\" block in the caller and pass its .json output here — keeps each pipeline's permissions colocated with the pipeline that uses them."
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
