output "secret_arn" {
  description = "ARN of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.db.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret."
  value       = aws_secretsmanager_secret.db.name
}

output "secret_version_id" {
  description = "Version ID of the stored secret value (used for dependency ordering)."
  value       = aws_secretsmanager_secret_version.db.version_id
}
