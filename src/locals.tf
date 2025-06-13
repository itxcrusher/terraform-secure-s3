############################################################
#  Shared locals – decoded once, consumed by every module  #
############################################################

# 1. Parse YAML user→roles map
locals {
  raw_users = yamldecode(
    file("${path.module}/modules/iam/users/user-roles.yaml")
  ).users

  #  { "tsmith-user" = ["readonly","auditor"], ... }
  user_role_map = {
    for u in local.raw_users : u.username => u.roles
  }
}

locals {
  raw_apps = yamldecode( file(var.apps_yaml_path) ).apps

  # key = "<name>-<env>-<keygroup>"
  apps_map = {
    for a in local.raw_apps :
    "${a.Name}-${a.Env}-${a.KeyGroupName}" => a
    if var.env_filter == "" || a.Env == var.env_filter
  }
}

################################
# Optional “surgical” extras   #
################################
variable "extra_role_actions" {
  description = "Granular additional actions per role (empty for now)"
  type        = map(list(string))
  default     = {}
}


