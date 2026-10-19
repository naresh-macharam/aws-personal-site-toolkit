locals {
  all_domains = var.include_www ? [var.domain_name, "www.${var.domain_name}"] : [var.domain_name]
  origins     = [for d in local.all_domains : "https://${d}"]

  default_colors = {
    bg          = "#0B0F14"
    surface     = "#121821"
    surface2    = "#1A222D"
    border      = "#26303B"
    borderSoft  = "#1E2731"
    ink         = "#F2F5F7"
    inkDim      = "#A9B4BE"
    inkFaint    = "#6C7784"
    accent      = "#34D8A6"
    accentDim   = "#1E5B4C"
  }
  colors = merge(local.default_colors, var.colors)

  name_prefix = replace(var.domain_name, ".", "-")
}

# ---------------------------------------------------------------------------
# 1. Static site infra (S3 + CloudFront + ACM + folder-URL routing)
# ---------------------------------------------------------------------------

module "site" {
  source = "./modules/static-site"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name              = var.domain_name
  additional_domain_names  = var.include_www ? ["www.${var.domain_name}"] : []
  route53_zone_id          = var.route53_zone_id
  price_class              = var.price_class
  tags                     = var.tags
}

# ---------------------------------------------------------------------------
# 2. GitHub OIDC provider
# ---------------------------------------------------------------------------

module "oidc_provider" {
  source          = "./modules/github-oidc-provider"
  create_provider = var.create_oidc_provider
  tags            = var.tags
}

# ---------------------------------------------------------------------------
# 3. Two scoped deploy roles — homepage (everything except blog/*) and
#    blog (only blog/*). Each can never touch the other's content, even
#    by mistake.
# ---------------------------------------------------------------------------

data "aws_iam_policy_document" "homepage_deploy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.site.bucket_arn}/*"]
  }
  statement {
    effect    = "Deny"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.site.bucket_arn}/blog/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.site.bucket_arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.site.cloudfront_distribution_arn]
  }
}

module "homepage_role" {
  source = "./modules/github-actions-role"

  oidc_provider_arn = module.oidc_provider.provider_arn
  github_org        = var.github_org
  github_repo       = var.homepage_repo
  github_owner_id   = var.github_owner_id
  github_repo_id    = var.homepage_repo_id
  role_name         = "${local.name_prefix}-homepage-deploy"
  policy_json       = data.aws_iam_policy_document.homepage_deploy.json
  tags              = var.tags
}

data "aws_iam_policy_document" "blog_deploy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${module.site.bucket_arn}/blog/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [module.site.bucket_arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["blog/*"]
    }
  }
  statement {
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [module.site.cloudfront_distribution_arn]
  }
}

module "blog_role" {
  source = "./modules/github-actions-role"

  oidc_provider_arn = module.oidc_provider.provider_arn
  github_org        = var.github_org
  github_repo       = var.blog_repo
  github_owner_id   = var.github_owner_id
  github_repo_id    = var.blog_repo_id
  role_name         = "${local.name_prefix}-blog-deploy"
  policy_json       = data.aws_iam_policy_document.blog_deploy.json
  tags              = var.tags
}

# ---------------------------------------------------------------------------
# 4. Contact pipeline (SES + Lambda + API Gateway)
# ---------------------------------------------------------------------------

module "contact_pipeline" {
  source = "./modules/contact-pipeline"

  name_prefix     = local.name_prefix
  recipient_email = var.contact_recipient_email
  sender_email    = var.contact_sender_email
  allowed_origins = local.origins
  aws_region      = var.aws_region
  tags            = var.tags
}

# ---------------------------------------------------------------------------
# 5. Generate the deploy workflows and a pre-filled hugo.yaml — nothing to
#    hand-copy or hand-edit for a standard setup.
# ---------------------------------------------------------------------------

resource "local_file" "homepage_workflow" {
  filename = "${path.module}/generated/deploy-homepage.yml"
  content = templatefile("${path.module}/templates/deploy-workflow.yml.tpl", {
    role_arn        = module.homepage_role.role_arn
    bucket_name     = module.site.bucket_name
    distribution_id = module.site.cloudfront_distribution_id
    aws_region      = var.aws_region
    toolkit_repo    = var.toolkit_repo
    toolkit_ref     = var.toolkit_ref
  })
}

resource "local_file" "blog_workflow" {
  filename = "${path.module}/generated/deploy-blog.yml"
  content = templatefile("${path.module}/templates/hugo-deploy-workflow.yml.tpl", {
    role_arn        = module.blog_role.role_arn
    bucket_name     = module.site.bucket_name
    distribution_id = module.site.cloudfront_distribution_id
    aws_region      = var.aws_region
    toolkit_repo    = var.toolkit_repo
    toolkit_ref     = var.toolkit_ref
  })
}

resource "local_file" "hugo_config" {
  filename = "${path.module}/generated/hugo.yaml"
  content = templatefile("${path.module}/templates/hugo-config.yaml.tpl", {
    domain_name       = var.domain_name
    site_title        = var.site_title
    site_description  = var.site_description
    logo_text         = local.name_prefix
    blog_headline     = var.blog_headline
    blog_subhead      = var.blog_subhead
    comment_endpoint  = module.contact_pipeline.invoke_url
    color_bg          = local.colors.bg
    color_surface     = local.colors.surface
    color_surface2    = local.colors.surface2
    color_border      = local.colors.border
    color_border_soft = local.colors.borderSoft
    color_ink         = local.colors.ink
    color_ink_dim     = local.colors.inkDim
    color_ink_faint   = local.colors.inkFaint
    color_accent      = local.colors.accent
    color_accent_dim  = local.colors.accentDim
  })
}

resource "local_file" "homepage_html" {
  filename = "${path.module}/generated/index.html"
  content = templatefile("${path.module}/../homepage-example/index.html.tpl", {
    contact_endpoint  = module.contact_pipeline.invoke_url
    color_bg          = local.colors.bg
    color_surface     = local.colors.surface
    color_surface2    = local.colors.surface2
    color_border      = local.colors.border
    color_border_soft = local.colors.borderSoft
    color_ink         = local.colors.ink
    color_ink_dim     = local.colors.inkDim
    color_ink_faint   = local.colors.inkFaint
    color_accent      = local.colors.accent
    color_accent_dim  = local.colors.accentDim
  })
}
