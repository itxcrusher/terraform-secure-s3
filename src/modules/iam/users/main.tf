############################################
# IAM USER + (optional) CONSOLE + API KEYS #
############################################

resource "aws_iam_user" "this" {
  name = var.user_name
  tags = merge(
    var.tags,
    { "ManagedBy" = "Terraform" }
  )
}

#################
# Console Login #
#################
resource "aws_iam_user_login_profile" "this" {
  count = var.create_console_password ? 1 : 0

  user                    = aws_iam_user.this.name
  password_length         = var.password_length
  password_reset_required = true
}

#############
# API Keys  #
#############
resource "aws_iam_access_key" "this" {
  user   = aws_iam_user.this.name
  status = "Active"
}

###############################
# Optional Policy Attachments #
###############################
resource "aws_iam_user_policy_attachment" "managed" {
  for_each   = toset(var.policy_arns)
  user       = aws_iam_user.this.name
  policy_arn = each.value
}

#########################
# (Nice-to-have) Export #
#########################
locals {
  csv_payload = templatefile(
    "${path.module}/templates/credentials.tftpl",
    {
      access_key = aws_iam_access_key.this.id
      secret_key = aws_iam_access_key.this.secret
      password = (length(aws_iam_user_login_profile.this) == 0
        ? "N/A"
      : aws_iam_user_login_profile.this[0].password)
    }
  )
}

resource "local_file" "creds_csv" {
  content  = local.csv_payload
  filename = "${path.module}/../../../../private/iam_access_keys/${var.user_name}-keys.csv"
}
