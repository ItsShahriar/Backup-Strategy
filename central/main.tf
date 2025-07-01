variable "central_account_id" {
  description = "AWS account ID for the central backup account"
  type        = string
}

resource "aws_backup_vault" "central_vault" {
  name          = "central-backup-vault"
  force_destroy = false
  tags = {
    Name = "CentralBackupVault"
  }
}

resource "aws_backup_plan" "daily_backup" {
  name = "daily-backup-plan"

  rule {
    rule_name         = "daily-backup-rule"
    target_vault_name = aws_backup_vault.central_vault.name
    schedule          = "cron(0 12 * * ? *)" # Daily at 12:00 UTC
    start_window      = 60    # 60 minutes
    completion_window = 180   # 3 hours

    lifecycle {
      delete_after = 30 # Days
    }

    copy_action {
      destination_vault_arn = aws_backup_vault.central_vault.arn
    }
  }
}

resource "aws_backup_vault_lock_configuration" "vault_lock" {
  backup_vault_name   = aws_backup_vault.central_vault.name
  changeable_for_days = 7
  min_retention_days  = 30
  max_retention_days  = 365
}

resource "aws_iam_policy" "allow_role_creation" {
  name        = "AllowWorkloadRoleCreation"
  description = "Allows workload accounts to create their backup roles"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:PutRolePolicy",
          "iam:AttachRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole"
        ],
        Resource = "arn:aws:iam::${var.central_account_id}:role/WorkloadBackupRole-*"
      }
    ]
  })
}

resource "aws_iam_role" "central_backup_role" {
  name = "AWSBackupServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "backup.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_service_policy" {
  role       = aws_iam_role.central_backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}