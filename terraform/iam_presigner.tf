# -------------------------------------------------------------------
# IAM User (Presigner) + Detachable Policy
# -------------------------------------------------------------------

resource "aws_iam_user" "presigner" {
  name = var.presigner_user_name
}

resource "aws_iam_policy" "presigner_policy" {
  name        = "${var.presigner_user_name}-policy"
  description = "Allows ${var.presigner_user_name} to get objects from ${aws_s3_bucket.secure_bucket.id}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowGetObjectFromS3"
        Effect = "Allow"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.secure_bucket.arn}/*"
      }
      # (Optional) Add s3:ListBucket if needed:
      # {
      #   Sid    = "AllowListBucket"
      #   Effect = "Allow"
      #   Action = ["s3:ListBucket"]
      #   Resource = aws_s3_bucket.secure_bucket.arn
      # }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_presigner" {
  user       = aws_iam_user.presigner.name
  policy_arn = aws_iam_policy.presigner_policy.arn
}

# Generate access key for the presigner user (optional; remove if you handle creds differently)
resource "aws_iam_access_key" "presigner_key" {
  user = aws_iam_user.presigner.name

  # IMPORTANT: Do NOT commit the resulting secret to Git. 
  # Use a secrets manager or copy manually.
}
