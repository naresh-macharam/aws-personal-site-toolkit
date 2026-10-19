module "oidc_provider" {
  source          = "../../modules/github-oidc-provider"
  create_provider = false

  tags = {
    Project   = "aws-personal-site-toolkit"
    ManagedBy = "terraform"
  }
}

# Minimal, harmless permission set — just enough to prove the role can be
# assumed and used for something real. sts:GetCallerIdentity actually
# requires no IAM permission at all for any authenticated principal, but
# including it keeps this policy meaningful rather than empty.
data "aws_iam_policy_document" "test_permissions" {
  statement {
    effect    = "Allow"
    actions   = ["sts:GetCallerIdentity"]
    resources = ["*"]
  }
}

module "test_role" {
  source = "../../modules/github-actions-role"

  oidc_provider_arn = module.oidc_provider.provider_arn
  github_org        = var.github_org
  github_repo       = var.test_repo
  role_name         = "github-actions-oidc-test"
  policy_json       = data.aws_iam_policy_document.test_permissions.json

  tags = {
    Project     = "aws-personal-site-toolkit"
    Environment = "test-oidc"
    ManagedBy   = "terraform"
  }
}

output "role_arn" {
  value = module.test_role.role_arn
}
