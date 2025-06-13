############################################
# Root module #
############################################

####################
# IAM – Users      #
####################
module "iam_users" {
  for_each = local.user_role_map
  source   = "./modules/iam/users"

  user_name               = each.key
  create_console_password = !contains(each.value, "serviceAccount")
}

####################
# IAM – Roles      #
####################
locals {
  role_matrix = {
    admin = {
      base_actions   = ["*"]
      extra_actions  = lookup(var.extra_role_actions, "admin", [])
      principal_arns = [for u, m in module.iam_users : m.arn if contains(local.user_role_map[u], "admin")]
    }
    developer = {
      base_actions   = ["s3:*", "cloudfront:*", "ses:*", "secretsmanager:*"]
      extra_actions  = lookup(var.extra_role_actions, "developer", [])
      principal_arns = [for u, m in module.iam_users : m.arn if contains(local.user_role_map[u], "developer")]
    }
    serviceAccount = {
      base_actions   = ["s3:*", "cloudfront:*", "ses:*", "secretsmanager:*"]
      extra_actions  = lookup(var.extra_role_actions, "serviceAccount", [])
      principal_arns = [for u, m in module.iam_users : m.arn if contains(local.user_role_map[u], "serviceAccount")]
    }
    readOnly = {
      base_actions   = ["s3:Get*", "cloudfront:Get*", "ses:Get*", "secretsmanager:GetSecretValue"]
      extra_actions  = lookup(var.extra_role_actions, "readOnly", [])
      principal_arns = [for u, m in module.iam_users : m.arn if contains(local.user_role_map[u], "readOnly")]
    }
  }
}

module "iam_roles" {
  source      = "./modules/iam/roles"
  role_matrix = local.role_matrix
}

####################
# S3  + CloudFront #
####################
module "s3_module" {
  for_each = toset(var.app-names-list)
  source   = "./modules/s3"

  s3_object = {
    AppName        = split("-", each.key)[0]
    AppEnvironment = split("-", each.key)[1]
    KeyGroupName   = split("-", each.key)[2]
  }

  role_arns = values(module.iam_roles.role_arns)

  # ensure roles (and their ARNs) exist before bucket policies
  depends_on = [module.iam_roles]
}

##########################
# Helper locals for SA   #
##########################
locals {
  sa_access_keys = [
    for u, rs in local.user_role_map :
    module.iam_users[u].access_key_id
    if contains(rs, "serviceAccount")
  ]
  sa_secret_keys = [
    for u, rs in local.user_role_map :
    module.iam_users[u].secret_access_key
    if contains(rs, "serviceAccount")
  ]
}

##########################
# Secrets Manager (all)  #
##########################
module "secretManager_module" {
  for_each = toset(var.app-names-list)
  source   = "./modules/secret_manager"

  secretManager_object = {
    AppName        = split("-", each.key)[0]
    AppEnvironment = split("-", each.key)[1]
  }

  # First serviceAccount creds (or empty strings via try)
  iam_access_key_id     = try(local.sa_access_keys[0], "")
  iam_secret_access_key = try(local.sa_secret_keys[0], "")

  cloudfront_key_pair_id         = module.s3_module[each.key].cloudfront_key_pair_id
  cloudfront_distribution_domain = module.s3_module[each.key].cloudfront_distribution_domain

  # auto-compute private-key path for this app-env
  cloudfront_private_key = file(
    "${path.module}/../private/cloudfront_keys/${split("-", each.key)[0]}-${split("-", each.key)[1]}-private-key.pem"
  )

  s3_bucket_name = module.s3_module[each.key].s3_bucket_name
}

###############################################################################
# Assertion: at least one serviceAccount user exists                         #
###############################################################################
check "service_account_present" {
  assert {
    condition     = length(local.sa_access_keys) > 0
    error_message = "No user with role 'serviceAccount' found in user-roles.yaml."
  }
}