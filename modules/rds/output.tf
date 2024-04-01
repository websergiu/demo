output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.default.address
}
output "secret_manager_db_arn" {
  description = "arn secret"
  value       = aws_secretsmanager_secret.db_password.arn
}