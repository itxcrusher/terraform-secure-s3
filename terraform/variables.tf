variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string
}

variable "public_key_path" {
  description = <<-EOT
    Path to your CloudFront public key file (PEM-encoded).
    Example: "keys/public_key.pem"
  EOT
  type = string
}

variable "public_key_name" {
  description = "Friendly name for the CloudFront public key"
  type        = string
  default     = "cf-public-key"
}

variable "presigner_user_name" {
  description = "IAM user name that will generate/get presigned URLs"
  type        = string
  default     = "presigner"
}

variable "allowed_ip_cidr" {
  description = <<-EOT
    (Optional) A CIDR range to further restrict S3 bucket policy.
    Leave blank if not needed.
  EOT
  type    = string
  default = ""
}
