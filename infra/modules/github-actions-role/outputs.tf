output "role_arn" {
  description = "Put this in the role-to-assume field of your workflow's configure-aws-credentials step"
  value       = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}
