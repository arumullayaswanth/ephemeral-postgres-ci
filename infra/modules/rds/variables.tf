variable "name" {
  description = "Name prefix for the RDS instance and related resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC the RDS instance and its security group live in."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the DB subnet group (use at least two private subnets in different AZs)."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least two subnet IDs in different availability zones."
  }
}

variable "engine_version" {
  description = "PostgreSQL major version (e.g. 16). AWS picks the latest minor."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Initial storage in GB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Upper limit for storage autoscaling in GB. Set equal to allocated_storage to disable."
  type        = number
  default     = 100
}

variable "db_name" {
  description = "Name of the initial database created on the instance."
  type        = string
  default     = "postgres"
}

variable "master_username" {
  description = "Master (admin) username. Must have CREATE DATABASE privileges."
  type        = string
  default     = "ci_admin"
}

variable "master_password" {
  description = "Master password. Pass via TF_VAR_* or a non-committed tfvars."
  type        = string
  sensitive   = true
}

variable "port" {
  description = "PostgreSQL port."
  type        = number
  default     = 5432
}

variable "multi_az" {
  description = "Enable Multi-AZ for high availability."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Whether the instance is publicly accessible. Keep false."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups. 0 disables backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the instance."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Set false for production."
  type        = bool
  default     = true
}

variable "allowed_security_group_ids" {
  description = "Security group IDs allowed to connect to the DB on its port (e.g. the EC2 client SG)."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}
