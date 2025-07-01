output "backup_vault_arn" {
  value = aws_backup_vault.central_vault.arn
}

output "backup_plan_id" {
  value = aws_backup_plan.daily_backup.id
}

output "role_creation_policy_arn" {
  value = aws_iam_policy.allow_role_creation.arn
}