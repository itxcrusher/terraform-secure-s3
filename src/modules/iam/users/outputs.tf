output "arn" {
  value       = aws_iam_user.this.arn
  description = "User ARN"
}

output "access_key_id" {
  value       = aws_iam_access_key.this.id
  description = "Access key ID"
}

output "secret_access_key" {
  value       = aws_iam_access_key.this.secret
  description = "Secret access key"
  sensitive   = true
}
