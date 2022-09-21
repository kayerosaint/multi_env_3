locals {
  role_users     = { for k in keys(var.roles) : k => toset(compact([for k1, v1 in var.users : v1.role == k ? k1 : ""])) }
  users_with_key = { for k in compact([for k, v in var.users : v.key ? k : ""]) : k => var.users[k] }
}

resource "aws_iam_role" "role" {
  for_each = var.roles

  name = each.key

  managed_policy_arns = [aws_iam_policy.role_policy[each.key].arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = [for k in local.role_users[each.key] : aws_iam_user.user[k].arn]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "role_policy" {
  for_each = var.roles

  name = "${each.key}_role_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = each.value
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user" "user" {
  for_each = var.users

  name = each.value.name
}

resource "aws_iam_access_key" "access_key" {
  for_each = local.users_with_key

  user = aws_iam_user.user[each.value.name].name
}

resource "local_file" "aws_creds" {
  for_each = local.users_with_key

  content = templatefile("${path.module}/credentials.tpl", {
    aws_access_key_id     = aws_iam_access_key.access_key[each.key].id,
    aws_secret_access_key = aws_iam_access_key.access_key[each.key].secret,
    role_arn              = aws_iam_role.role[each.value.role].arn,
  })
  filename = "${path.module}/../../users/${aws_iam_access_key.access_key[each.key].user}_credentials"
}
