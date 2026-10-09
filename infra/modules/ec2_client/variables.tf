variable "name" {
  description = "Name prefix for the EC2 client and its security group."
  type        = string
}

variable "vpc_id" {
  description = "VPC the EC2 client is launched into (must match the RDS VPC)."
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the EC2 client. Use a private subnet with NAT for best security."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the DB client/runner."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 client. If null, the latest Amazon Linux 2023 AMI is used."
  type        = string
  default     = null
}

variable "key_name" {
  description = "Optional EC2 key pair name for SSH access. Prefer SSM Session Manager instead."
  type        = string
  default     = null
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP. Keep false for private-subnet clients."
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Existing IAM instance profile name to use when create_instance_profile is false."
  type        = string
  default     = null
}

variable "create_instance_profile" {
  description = "Create an IAM role + instance profile with SSM and secret-read access."
  type        = bool
  default     = true
}

variable "secret_arn" {
  description = "ARN of the DB secret the instance may read."
  type        = string
  default     = ""
}

variable "attach_secret_policy" {
  description = "Attach the secret-read policy to the instance role (static, plan-time flag)."
  type        = bool
  default     = true
}

variable "depends_on_arns" {
  description = "Opaque values used to order the instance after dependencies (e.g. the secret version)."
  type        = list(string)
  default     = []
}

variable "allow_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to the client. Empty disables SSH ingress."
  type        = list(string)
  default     = []
}

variable "region" {
  description = "AWS region, used by the bootstrap script to read the secret."
  type        = string
}

variable "secret_name" {
  description = "Secrets Manager secret name holding DB credentials (used to seed data)."
  type        = string
  default     = ""
}

variable "seed_data" {
  description = "Whether to seed demo data into the database on first boot."
  type        = bool
  default     = false
}

variable "seed_sql" {
  description = "SQL executed to seed demo data (concatenated migrations/*.sql)."
  type        = string
  default     = ""
}

# --- GitHub self-hosted runner (auto-registration) ---

variable "register_runner" {
  description = "Register this instance as a GitHub Actions self-hosted runner on boot."
  type        = bool
  default     = false
}

variable "github_owner" {
  description = "GitHub org/user that owns the repo (for runner registration)."
  type        = string
  default     = ""
}

variable "github_repo" {
  description = "Repository name (for runner registration)."
  type        = string
  default     = ""
}

variable "runner_pat" {
  description = "GitHub PAT (repo scope) used to fetch a runner registration token."
  type        = string
  default     = ""
  sensitive   = true
}

variable "runner_name" {
  description = "Name shown for the self-hosted runner in GitHub."
  type        = string
  default     = "ephemeral-postgres-ci-runner"
}

variable "runner_version" {
  description = "GitHub Actions runner version (no leading v). Must be >= 2.329.0 (GitHub enforces a minimum)."
  type        = string
  default     = "2.329.0"
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}
