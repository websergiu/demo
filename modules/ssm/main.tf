module "session-manager-settings" {
  source = "gazoakley/session-manager-settings/aws"

  s3_bucket_name                = var.s3_bucket_name
  cloudwatch_log_group_name     = var.cloudwatch_log_group_name
  cloudwatch_encryption_enabled = var.cloudwatch_encryption_enabled
  s3_encryption_enabled         = var.s3_encryption_enabled
}
