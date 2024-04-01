output "app_log_group_name" {
  value       = aws_cloudwatch_log_group.app.name
  description = "The name of the app log group"
}