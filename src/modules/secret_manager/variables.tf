variable "secretManager_object" {
  type = object({
    AppName        = string
    AppEnvironment = string
  })
}


variable "iam_access_key_id" {}
variable "iam_secret_access_key" {}
variable "cloudfront_key_pair_id" {}
variable "cloudfront_distribution_domain" {}
variable "cloudfront_private_key" {}
variable "s3_bucket_name" {}
