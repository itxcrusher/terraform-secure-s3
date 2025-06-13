variable "s3_object" {
  type = object({
    AppName        = string
    AppEnvironment = string
    KeyGroupName   = string
  })
}

variable "role_arns" {
  description = "List of IAM Role ARNs allowed to read/write this bucket"
  type        = list(string)
}

variable "enable_bucket_encryption" {
  description = "Turn on AES-256 default encryption for the bucket"
  type        = bool
  default     = false
}
