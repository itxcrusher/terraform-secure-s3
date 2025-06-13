################################
# S3 bucket   +  CloudFront OAI#
################################

resource "aws_s3_bucket" "this" {
  bucket = "${var.s3_object.AppName}-${var.s3_object.AppEnvironment}-test-bucket"
  tags = {
    Environment = var.s3_object.AppEnvironment
    ManagedBy   = "Terraform"
  }
}

#############################################
# Ownership, ACL, Public-access block       #
#############################################
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_acl" "this" {
  bucket     = aws_s3_bucket.this.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

###########################
# Versioning OFF by default
###########################
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Disabled" }
}

###################
# CloudFront OAI  #
###################
resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "${var.s3_object.AppName}-${var.s3_object.AppEnvironment}-oai"
}

#################################################
# Bucket Policy – OAI + Privileged Role ARNs    #
#################################################
data "aws_iam_policy_document" "bucket" {

  # 1. Allow CloudFront OAI
  statement {
    sid = "AllowCloudFrontRead"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  # 2. Allow ROLES to read (all roles)
  statement {
    sid = "AllowRolesRead"
    principals {
      type        = "AWS"
      identifiers = var.role_arns
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  # 3. Allow roles *except readOnly* to write/delete
  #    IAM policies already stop readOnly from writing, but if you
  #    want belt-and-braces, list only the write-capable role ARNs.
  statement {
    sid = "AllowWriteRoles"
    principals {
      type        = "AWS"
      identifiers = var.role_arns
    }
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }

  # 4. Deny insecure requests
  statement {
    sid       = "DenyUnEncrypted"
    effect    = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json
}

#########################################
# Optional server-side encryption toggle
#########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.enable_bucket_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

####################
# Outputs to caller
####################
output "s3_bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "cloudfront_distribution_domain" {
  value = module.cloudfront.cloudfront_distribution_domain
}

output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_key_pair_id" {
  value = module.cloudfront.cloudfront_key_pair_id
}

##################
# CloudFront sub-module call (unchanged logic)
##################
module "cloudfront" {
  source = "../cloudfront"

  cloudfront_object = {
    AppName                         = var.s3_object.AppName
    Environment                     = var.s3_object.AppEnvironment
    DomainName                      = aws_s3_bucket.this.bucket_domain_name
    Bucket_Regional_Domain_name     = aws_s3_bucket.this.bucket_regional_domain_name
    Origin_id                       = aws_s3_bucket.this.id
    Cloudfront_access_identity_path = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    KeyGroupName                    = var.s3_object.KeyGroupName
  }
}
