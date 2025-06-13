variable "role_matrix" {
  description = <<EOF
Map of roles to their definition.

Example:
{
  admin = {
    base_actions    = ["*"]
    extra_actions   = []
    principal_arns  = ["arn:aws:iam::123456789012:user/alice"]
  }
  developer = {
    base_actions    = ["s3:*", "cloudfront:*", "ses:*", "secretsmanager:*"]
    extra_actions   = ["dynamodb:*"]
    principal_arns  = ["arn:aws:iam::123456789012:user/bob"]
  }
}
EOF
  type = map(object({
    base_actions   = list(string)
    extra_actions  = list(string)
    principal_arns = list(string)
  }))
}

variable "tags" {
  description = "Common tags applied to every role"
  type        = map(string)
  default     = {}
}
