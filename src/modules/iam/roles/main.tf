############################################
# DYNAMIC ROLE + INLINE POLICY GENERATION  #
############################################

# Trust policy – one per role
data "aws_iam_policy_document" "trust" {
  for_each = var.role_matrix

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = each.value.principal_arns
    }
  }
}

# Inline permissions policy – one per role
data "aws_iam_policy_document" "policy" {
  for_each = var.role_matrix

  statement {
    sid       = "BaseActions"
    actions   = each.value.base_actions
    effect    = "Allow"
    resources = ["*"]
  }

  # Optional extra actions block
  dynamic "statement" {
    for_each = length(each.value.extra_actions) > 0 ? [1] : []
    content {
      sid       = "ExtraActions"
      actions   = each.value.extra_actions
      effect    = "Allow"
      resources = ["*"]
    }
  }
}

# Role resource
resource "aws_iam_role" "this" {
  for_each           = var.role_matrix
  name               = each.key
  assume_role_policy = data.aws_iam_policy_document.trust[each.key].json
  tags               = var.tags
}

# Attach inline policy
resource "aws_iam_role_policy" "inline" {
  for_each = var.role_matrix

  name   = "${each.key}-inline"
  role   = aws_iam_role.this[each.key].id
  policy = data.aws_iam_policy_document.policy[each.key].json
}
