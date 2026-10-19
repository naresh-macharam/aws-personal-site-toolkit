module "test_site" {
  source = "../../modules/static-site"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name     = var.test_domain
  route53_zone_id = var.route53_zone_id

  tags = {
    Project     = "aws-personal-site-toolkit"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

output "bucket_name" {
  value = module.test_site.bucket_name
}

output "cloudfront_distribution_id" {
  value = module.test_site.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  value = module.test_site.cloudfront_domain_name
}

output "acm_validation_records" {
  value = module.test_site.acm_validation_records
}

# ---------------------------------------------------------------------------
# Milestone 3 — the deploy role and a real, generated GitHub Actions
# workflow that deploys to this exact site, with no hand-typed ARNs.
# ---------------------------------------------------------------------------

# The OIDC provider already exists in this account (created manually,
# before this toolkit existed) — so create_provider = false tells the
# module to look it up instead of trying to create a duplicate.
module "oidc_provider" {
  source          = "../../modules/github-oidc-provider"
  create_provider = false

  tags = {
    Project   = "aws-personal-site-toolkit"
    ManagedBy = "terraform"
  }
}

data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.test_site.bucket_arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.test_site.bucket_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.test_site.cloudfront_distribution_arn]
  }
}

module "deploy_role" {
  source = "../../modules/github-actions-role"

  oidc_provider_arn = module.oidc_provider.provider_arn
  github_org        = var.github_org
  github_repo       = var.github_repo
  role_name         = "github-actions-test-site-deploy"
  policy_json       = data.aws_iam_policy_document.deploy_permissions.json

  tags = {
    Project     = "aws-personal-site-toolkit"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

# Generates the actual workflow file with real values already filled in —
# copy generated/deploy.yml straight into your test repo, no manual editing.
resource "local_file" "deploy_workflow" {
  filename = "${path.module}/generated/deploy.yml"
  content = templatefile("${path.module}/templates/deploy-workflow.yml.tpl", {
    role_arn        = module.deploy_role.role_arn
    bucket_name     = module.test_site.bucket_name
    distribution_id = module.test_site.cloudfront_distribution_id
    aws_region      = var.aws_region
  })
}

output "deploy_role_arn" {
  value = module.deploy_role.role_arn
}

output "generated_workflow_path" {
  description = "Copy this file into <your-test-repo>/.github/workflows/deploy.yml"
  value       = local_file.deploy_workflow.filename
}

# ---------------------------------------------------------------------------
# Milestone 4 — same pattern, scoped to the blog/ prefix only, with the
# Hugo build step included in the generated workflow.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "blog_deploy_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.test_site.bucket_arn}/blog/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.test_site.bucket_arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["blog/*"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.test_site.cloudfront_distribution_arn]
  }
}

module "blog_deploy_role" {
  source = "../../modules/github-actions-role"

  oidc_provider_arn = module.oidc_provider.provider_arn
  github_org        = var.github_org
  github_repo       = var.blog_github_repo
  role_name         = "github-actions-test-blog-deploy"
  policy_json       = data.aws_iam_policy_document.blog_deploy_permissions.json

  tags = {
    Project     = "aws-personal-site-toolkit"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

resource "local_file" "blog_deploy_workflow" {
  filename = "${path.module}/generated/deploy-blog.yml"
  content = templatefile("${path.module}/templates/hugo-deploy-workflow.yml.tpl", {
    role_arn        = module.blog_deploy_role.role_arn
    bucket_name     = module.test_site.bucket_name
    distribution_id = module.test_site.cloudfront_distribution_id
    aws_region      = var.aws_region
  })
}

output "generated_blog_workflow_path" {
  value = local_file.blog_deploy_workflow.filename
}

# ---------------------------------------------------------------------------
# Milestone 5 — the SES/Lambda/API Gateway contact pipeline
# ---------------------------------------------------------------------------

module "contact_pipeline" {
  source = "../../modules/contact-pipeline"

  name_prefix     = "test-site"
  recipient_email = var.contact_recipient_email
  sender_email    = var.contact_sender_email
  allowed_origins = [
    "https://${var.test_domain}",
    "https://www.${var.test_domain}",
  ]
  aws_region      = var.aws_region

  tags = {
    Project     = "aws-personal-site-toolkit"
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

output "contact_endpoint" {
  description = "Put this in your homepage's CONTACT_ENDPOINT and hugo.yaml's commentEndpoint"
  value       = module.contact_pipeline.invoke_url
}

output "contact_sender_verification_note" {
  value = module.contact_pipeline.sender_verification_note
}
