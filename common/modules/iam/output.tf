output "roles" {
  value = aws_iam_role.role
}

output "users" {
  value = aws_iam_user.user
}

output "access_keys" {
  value = aws_iam_access_key.access_key
}
