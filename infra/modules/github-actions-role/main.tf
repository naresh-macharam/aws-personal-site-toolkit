locals {
  # GitHub's "immutable subject claims" rollout (July 15, 2026) embeds
  # numeric owner/repo IDs in the sub claim for newly created repos:
  #   repo:org@OWNER_ID/repo@REPO_ID:ref:refs/heads/main
  # instead of the legacy:
  #   repo:org/repo:ref:refs/heads/main
  # A trust policy built for the legacy format will never match a
  # token using the new one, and vice versa — this is the #1 cause of
  # "Not authorized to perform sts:AssumeRoleWithWebIdentity" for any
  # repo created after that date. Auto-detect which to build based on
  # whether IDs were supplied.
  use_immutable_format = var.github_owner_id != null && var.github_repo_id != null

  repo_subject = local.use_immutable_format ? (
    "${var.github_org}@${var.github_owner_id}/${var.github_repo}@${var.github_repo_id}"
  ) : (
    "${var.github_org}/${var.github_repo}"
  )
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.repo_subject}:${var.allowed_ref}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.role_name}-permissions"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}
