# Cloudfront 
# Benifits
# Devilers content s3 bucket content through CDN (content develiery network), which improvement speed, lowers latency, and adds content caching
# Content Management - Add content must have presign url to access, and will expire after time expires



locals {
  # Allowed Request
  Allowed_Method = {
    DELETE  = "DELETE"
    GET     = "GET"
    HEAD    = "HEAD"
    OPTIONS = "OPTIONS"
    PATCH   = "PATCH"
    POST    = "POST"
    PUT     = "PUT"
  }

  # PRICE_CLASS_100 - USA, Canada, Europe, & Israel.
  # PRICE_CLASS_200 - PRICE_CLASS_100 + South Africa, Kenya, Middle East, Japan, Singapore, South Korea, Taiwan, Hong Kong, & Philippines.
  # PRICE_CLASS_ALL - All locations, Recommendation
  Price_Class = {
    PRICE_CLASS_100 = "PriceClass_100"
    PRICE_CLASS_200 = "PriceClass_200"
    PRICE_CLASS_ALL = "PriceClass_All"
  }

  Geo_restriction_restriction_type = {
    None      = "none"
    Whitelist = "whitelist"
  }

  Geo_restriction_locations = {
    UnitedStates = "US"
    Canada       = "CA"
    GreatBritain = "GB"
    Germany      = "DE"
  }

  Viewer_Policy = {
    Allow_All         = "allow-all"
    Redirect_to_https = "redirect-to-https"
  }

  Encoding = "${path.module}/../../../private/cloudfront_keys/${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-public-key.pem"
}



resource "aws_cloudfront_public_key" "main" {
  name    = "${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-public-key"
  comment = "Created public key using terraform"
  # Replace with your actual public key
  encoded_key = file(local.Encoding)
}


# How many keys for one key group 100?
resource "aws_cloudfront_key_group" "main" {
  name    = "${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-key-group"
  comment = "Created key group using terraform"
  items   = [aws_cloudfront_public_key.main.id]
}


# Resource to only allow access to s3 bucket through cloudfront cdn
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-cloudfront-s3-oac"
  description                       = "CloudFront S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# Will take up to 15 min to create, update, or destory this resource
# aws_cloudfront_distribution.main: Still creating... [5m50s elapsed]
resource "aws_cloudfront_distribution" "main" {

  enabled             = true
  default_root_object = "index.html"
  price_class         = local.Price_Class.PRICE_CLASS_ALL
  comment             = "${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-cloudfront"

  # Primary origin with default cache behavior
  origin {
    domain_name = var.cloudfront_object.Bucket_Regional_Domain_name
    origin_id   = var.cloudfront_object.Origin_id
    s3_origin_config {
      origin_access_identity = var.cloudfront_object.Cloudfront_access_identity_path
    }
  }


  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.cloudfront_object.Origin_id
    viewer_protocol_policy = local.Viewer_Policy.Redirect_to_https

    # Can add up to 5 key group for key rotating
    trusted_key_groups = [aws_cloudfront_key_group.main.id]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = local.Geo_restriction_restriction_type.None
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment = "${var.cloudfront_object.Environment}"
  }
}


locals {
  Aws_cloudfront_to_csv = "Aws_CloudFront_KeyPairId,Aws_Cloudfront_DistributionSubdomain,S3_Bucket\n${aws_cloudfront_public_key.main.id},${aws_cloudfront_distribution.main.domain_name},${var.cloudfront_object.Origin_id}"
}


resource "local_file" "keypair_n_DistributionSubdomain" {
  content  = local.Aws_cloudfront_to_csv
  filename = "${path.module}/../../../private/cloudfront_keys/${var.cloudfront_object.AppName}-${var.cloudfront_object.Environment}-KeyPair-n-DistributionSubdomain.csv"
}


output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.main.id
}

output "cloudfront_key_pair_id" {
  value = aws_cloudfront_public_key.main.id
}
