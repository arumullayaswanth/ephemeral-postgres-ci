output "ec2_client_instance_id" {
  description = "ID of the EC2 client that connects to RDS."
  value       = module.ec2_client.instance_id
}

output "ec2_client_private_ip" {
  description = "Private IP of the EC2 client."
  value       = module.ec2_client.private_ip
}

output "ec2_client_security_group_id" {
  description = "Security group ID of the EC2 client (allowed source for RDS)."
  value       = module.ec2_client.security_group_id
}

output "rds_instance_id" {
  description = "Identifier of the created RDS instance."
  value       = module.rds.instance_id
}

output "rds_endpoint" {
  description = "Address (hostname) of the created RDS instance."
  value       = module.rds.address
}

output "rds_port" {
  description = "Port of the created RDS instance."
  value       = module.rds.port
}

output "rds_security_group_id" {
  description = "Security group ID attached to the RDS instance."
  value       = module.rds.security_group_id
}

output "rds_db_name" {
  description = "Initial database name on the RDS instance."
  value       = module.rds.db_name
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials."
  value       = module.secrets.secret_arn
}

output "db_secret_name" {
  description = "Name of the Secrets Manager secret. Set as GitHub variable DB_SECRET_NAME."
  value       = module.secrets.secret_name
}
