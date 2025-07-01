variable "workload_account_name" {
  description = "Name of the workload account"
  type        = string
}

variable "workload_account_id" {
  description = "AWS account ID of the workload account"
  type        = string
}

variable "central_account_id" {
  description = "AWS account ID of the central backup account"
  type        = string
}

variable "backup_plan_id" {
  description = "ID of the backup plan in the central account"
  type        = string
}