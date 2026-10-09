variable "aws_region" {
  description = "AWS region where the RDS instance and EC2 client live."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "ci"

  validation {
    condition     = contains(["ci", "dev", "staging", "prod"], var.environment)
    error_message = "Must be one of: ci, dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project identifier used to name and tag resources."
  type        = string
  default     = "ephemeral-postgres-ci"
}

# --- EC2 client ----------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type for the DB client."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 client. If null, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair for SSH. Prefer SSM Session Manager."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Assign a public IP to the EC2 client. True so SSM works in the default (public) VPC."
  type        = bool
  default     = true
}

variable "ec2_instance_profile" {
  description = <<-EOT
    Optional IAM instance profile name for the EC2 client. Attach one that
    grants SSM access and/or secretsmanager:GetSecretValue if the client reads
    DB credentials from Secrets Manager at runtime.
  EOT
  type        = string
  default     = null
}

variable "allow_ssh_cidrs" {
  description = "CIDRs allowed to SSH to the EC2 client. Empty disables SSH."
  type        = list(string)
  default     = []
}

# --- RDS PostgreSQL (created by Terraform) ------------------------------

variable "db_engine_version" {
  description = "PostgreSQL major version. Major-only lets AWS pick the latest minor."
  type        = string
  default     = "16"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial storage in GB."
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the initial database created on the instance."
  type        = string
  default     = "postgres"
}

variable "db_master_username" {
  description = "Master (admin) username with CREATE DATABASE privileges."
  type        = string
  default     = "ci_admin"
}

variable "db_password_length" {
  description = "Length of the auto-generated DB master password."
  type        = number
  default     = 24
}

variable "secret_recovery_window_days" {
  description = <<-EOT
    Days before a deleted Secrets Manager secret is permanently removed.
    Set to 0 so destroy fully deletes it and a re-apply with the same name
    does not hit a "scheduled for deletion" conflict.
  EOT
  type        = number
  default     = 0
}

variable "ec2_create_instance_profile" {
  description = "Create an IAM instance profile for the EC2 client (SSM + secret read)."
  type        = bool
  default     = true
}

variable "seed_data" {
  description = "Seed demo data into the database on first EC2 boot."
  type        = bool
  default     = true
}

# --- GitHub self-hosted runner (auto-registration) ---

variable "register_runner" {
  description = "Auto-register the EC2 client as a GitHub Actions self-hosted runner."
  type        = bool
  default     = true
}

variable "github_owner" {
  description = "GitHub org/user that owns the repo. Supplied from the workflow (github.repository_owner)."
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "Repository name. Supplied from the workflow (github.event.repository.name)."
  type        = string
  default     = ""
}

variable "github_runner_pat" {
  description = "GitHub PAT (repo scope). Pass via TF_VAR_github_runner_pat; never commit it."
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for the RDS instance."
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Prevent accidental deletion of the RDS instance."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Set false for production."
  type        = bool
  default     = true
}
