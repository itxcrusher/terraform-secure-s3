output "role_arns" {
  value = {
    for k, v in aws_iam_role.this : k => v.arn
  }
  description = "Map of role name → role ARN"
}
