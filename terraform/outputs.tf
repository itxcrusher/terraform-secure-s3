output "s3_bucket_name" {
  description = "Locked-down S3 bucket name"
  value       = aws_s3_bucket.secure_bucket.bucket
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain (e.g., d1234abcd.cloudfront.net)"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cf_key_group_id" {
  description = "CloudFront Key Group ID (for signing URLs)"
  value       = aws_cloudfront_key_group.cf_key_group.id
}

output "presigner_user_access_key_id" {
  description = "Access Key ID for the presigner user (store secret separately!)"
  value       = aws_iam_access_key.presigner_key.id
}

output "presigner_user_secret_access_key" {
  description = "Secret Access Key for the presigner user"
  value       = aws_iam_access_key.presigner_key.secret
  sensitive   = true
}
