# -------------------------------------------------------------------
# CloudFront Public Key + Key Group + Distribution
# -------------------------------------------------------------------

# Import your existing public key PEM
resource "aws_cloudfront_public_key" "cf_pubkey" {
  name        = var.public_key_name
  encoded_key = file(var.public_key_path)
  comment     = "Imported public key for signed URLs"
}

resource "aws_cloudfront_key_group" "cf_key_group" {
  name = "${var.public_key_name}-group"
  public_key_ids = [
    aws_cloudfront_public_key.cf_pubkey.id
  ]
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true

  origin {
    domain_name = aws_s3_bucket.secure_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.secure_bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "S3-${aws_s3_bucket.secure_bucket.bucket}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    # Only serve if request is signed by our Key Group
    trusted_key_groups = [
      aws_cloudfront_key_group.cf_key_group.id
    ]

    default_ttl = 3600
    max_ttl     = 86400
    min_ttl     = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # Default CloudFront certificate (*.cloudfront.net). For a custom domain, switch to ACM.
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

  tags = {
    Name = "cf-secure-${aws_s3_bucket.secure_bucket.bucket}"
  }
}
