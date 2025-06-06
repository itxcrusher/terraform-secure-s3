# -------------------------------------------------------------------
# Secure S3 Bucket (Block ALL Public Access + OAI Policy)
# -------------------------------------------------------------------

resource "aws_s3_bucket" "secure_bucket" {
  bucket = var.bucket_name

  # Lock down public access completely:
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = {
    Name        = var.bucket_name
    Environment = "prod"
  }
}

# CloudFront Origin Access Identity (OAI)
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for accessing S3 bucket ${aws_s3_bucket.secure_bucket.id}"
}

# S3 Bucket Policy: only allow CloudFront OAI to GetObject
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontGetObject"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        }
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.secure_bucket.arn}/*"
      }
    ]
  })
}
