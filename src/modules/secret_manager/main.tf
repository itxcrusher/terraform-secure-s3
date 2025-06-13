


# locals {
#   secret_manger_from_yaml = yamldecode(file("${path.module}/../../../private/secret_manager_secrets/${var.secretManager_object.AppName}-${var.secretManager_object.AppEnvironment}-secrets-manager.yaml")).secrets
#   # secret_manger_from_yaml_list = [for index, obj in local.secret_manger_from_yaml : obj]
#   secret_manger_to_singleObject = { for item in local.secret_manger_from_yaml : item.key => item.value }
# }


resource "aws_secretsmanager_secret" "main" {
  name                    = "${var.secretManager_object.AppName}-${var.secretManager_object.AppEnvironment}-secrets-manager"
  description             = "Will be used to keep app secrets for dev"
  recovery_window_in_days = "0"
  lifecycle {
    create_before_destroy = true
  }
}

# # # # secret_id - You can specify either the Amazon Resource Name (ARN) or the friendly name of the secret. The secret must already exist
# # # # secret_string - The seceret value
resource "aws_secretsmanager_secret_version" "main" {
  secret_id = aws_secretsmanager_secret.main.id

  secret_string = jsonencode({
    AWS_IAM_ServiceUser_AccessKeyId      = var.iam_access_key_id
    AWS_IAM_ServiceUser_SecretAccessKey  = var.iam_secret_access_key
    AWS_CloudFront_KeyPairId             = var.cloudfront_key_pair_id
    AWS_Cloudfront_DistributionSubdomain = var.cloudfront_distribution_domain
    AWS_Cloudfront_Private_Key           = var.cloudfront_private_key
    Bucket_name                          = var.s3_bucket_name
  })


  # secret_string  = jsonencode(local.secret_manger_to_singleObject)
  version_stages = ["AWSCURRENT"]
}