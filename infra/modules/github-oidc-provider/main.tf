# ---------------------------------------------------------------------------
# GitHub OIDC identity provider — ONE per AWS account, not one per repo.
#
# Controlled by var.create_provider:
#   true  (default) -> this module creates a brand new provider. Use this
#                       if your AWS account doesn't have one yet.
#   false            -> this module looks up an existing provider instead,
#                       via a data source. Use this if you (or an earlier
#                       manual setup) already created one — this is your
#                       case, since you made yours by hand originally.
#
# Terraform cannot auto-detect which situation you're in — a data source
# either finds the resource or hard-errors, it can't fall back to creating
# one. So this toggle is the standard, explicit way to handle both cases
# with one reusable module.
# ---------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_provider ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
  ]

  tags = var.tags
}

data "aws_iam_openid_connect_provider" "existing" {
  count = var.create_provider ? 0 : 1

  url = "https://token.actions.githubusercontent.com"
}
