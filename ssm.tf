module "ssm" {
  source                        = "./modules/ssm"
  s3_bucket_name                = local.var.ssm.s3_bucket_name
  cloudwatch_log_group_name     = local.var.ssm.cloudwatch_log_group_name
  cloudwatch_encryption_enabled = local.var.ssm.cloudwatch_encryption_enabled
  s3_encryption_enabled         = local.var.ssm.s3_encryption_enabled
}
