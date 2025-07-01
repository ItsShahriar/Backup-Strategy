#module "central" {
#  source  = "./central"
#  providers = {
#    aws = aws.central
#  }
#}
module "central" {
  source  = "./central"
  providers = {
    aws = aws.central
  }

  central_account_id = var.central_account_id  # Pass the variable to the module
}

module "workload" {
  for_each = var.workload_account_ids
  source   = "./workload"
  providers = {
    aws.central   = aws.central
    aws.workload  = aws.workload
  }

  workload_account_name = each.key
  workload_account_id   = each.value
  central_account_id    = var.central_account_id
  backup_plan_id        = module.central.backup_plan_id
}