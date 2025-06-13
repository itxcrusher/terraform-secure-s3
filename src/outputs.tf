output "bucket_names" {
  value = { for k, m in module.s3_module : k => m.s3_bucket_name }
}

output "cloudfront_distribution_domains" {
  value = { for k, m in module.s3_module : k => m.cloudfront_distribution_domain }
}

output "cloudfront_distribution_ids" {
  value = { for k, m in module.s3_module : k => m.cloudfront_distribution_id }
}

output "cloudfront_key_pair_ids" {
  value = { for k, m in module.s3_module : k => m.cloudfront_key_pair_id }
}
