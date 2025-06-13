# DomainName - The name of the s3 bucket
# Origin_id - The s3 bucket origin id
# 
variable "cloudfront_object" {
  type = object({
    AppName                         = string
    Environment                     = string
    DomainName                      = string
    Bucket_Regional_Domain_name     = string
    Origin_id                       = string
    Origin_access_control_id        = optional(string)
    Cloudfront_access_identity_path = string
    KeyGroupName                    = string
  })
}