variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "central_account_id" {
  description = "AWS account ID for the central backup account"
  type        = string
}

variable "workload_account_ids" {
  description = "Map of workload account names to their AWS account IDs"
  type        = map(string)
  default     = {}
}