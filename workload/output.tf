output "backup_role_arn" {
  value = aws_iam_role.backup_service_role.arn
}

output "central_role_arn" {
  value = aws_iam_role.central_backup_role.arn
}