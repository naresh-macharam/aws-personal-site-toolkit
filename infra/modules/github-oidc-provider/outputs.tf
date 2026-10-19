output "provider_arn" {
  description = "Pass this into every github-actions-role module instance"
  value = var.create_provider ? (
    aws_iam_openid_connect_provider.github[0].arn
  ) : (
    data.aws_iam_openid_connect_provider.existing[0].arn
  )
}
