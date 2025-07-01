# IAM role for AWS Backup service in workload account
resource "aws_iam_role" "backup_service_role" {
  provider = aws.workload
  name     = "AWSBackupServiceRole-${var.workload_account_name}"

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
  provider   = aws.workload
  role       = aws_iam_role.backup_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Cross-account role in central account created by the workload account
resource "aws_iam_role" "central_backup_role" {
  provider = aws.central
  name     = "WorkloadBackupRole-${var.workload_account_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::${var.central_account_id}:root"
      },
      Action = "sts:AssumeRole",
      Condition = {
        StringEquals = {
          "sts:ExternalId" = "backup-${var.workload_account_id}"
        }
      }
    }]
  })

  tags = {
    WorkloadAccount = var.workload_account_name
  }
}

resource "aws_iam_role_policy" "central_backup_policy" {
  provider = aws.central
  name     = "WorkloadBackupPolicy-${var.workload_account_name}"
  role     = aws_iam_role.central_backup_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "backup:CopyIntoBackupVault",
          "backup:StartBackupJob",
          "backup:StartRestoreJob",
          "backup:DescribeBackupJob",
          "backup:ListBackupJobs"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# Backup selection in central account for this workload's resources
resource "aws_backup_selection" "workload_selection" {
  provider   = aws.central
  name       = "backup-selection-${var.workload_account_name}"
  iam_role_arn = aws_iam_role.central_backup_role.arn
  plan_id    = var.backup_plan_id

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "true"
  }

  depends_on = [
    aws_iam_role.central_backup_role,
    aws_iam_role_policy_attachment.backup_service_policy
  ]
}