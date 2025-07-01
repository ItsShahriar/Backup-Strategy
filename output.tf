output "central_backup_vault_arn" {
  value = module.central.backup_vault_arn
}

output "central_backup_plan_id" {
  value = module.central.backup_plan_id
}

output "workload_backup_roles" {
  value = { for k, v in module.workload : k => v.backup_role_arn }
}