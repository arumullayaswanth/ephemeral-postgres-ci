output "instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.id
}

output "address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "endpoint" {
  description = "RDS endpoint in host:port form."
  value       = aws_db_instance.this.endpoint
}

output "security_group_id" {
  description = "Security group ID attached to the RDS instance."
  value       = aws_security_group.rds.id
}

output "db_name" {
  description = "Initial database name."
  value       = aws_db_instance.this.db_name
}
