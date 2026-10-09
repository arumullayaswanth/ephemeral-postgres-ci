output "instance_id" {
  description = "ID of the EC2 client instance."
  value       = aws_instance.client.id
}

output "private_ip" {
  description = "Private IP of the EC2 client."
  value       = aws_instance.client.private_ip
}

output "security_group_id" {
  description = "Security group ID of the EC2 client (source for RDS access)."
  value       = aws_security_group.client.id
}
