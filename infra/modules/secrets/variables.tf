variable "secret_name" {
  description = "Name of the Secrets Manager secret holding DB credentials."
  type        = string
}

variable "db_password" {
  description = "DB master password to store in the secret (generated in the root module)."
  type        = string
  sensitive   = true
}

variable "recovery_window_days" {
  description = "Days before a deleted secret is permanently removed. 0 = delete immediately."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to the secret."
  type        = map(string)
  default     = {}
}

variable "db_host" {
  description = "RDS endpoint hostname stored in the secret."
  type        = string
}

variable "db_port" {
  description = "RDS port stored in the secret."
  type        = number
  default     = 5432
}

variable "db_username" {
  description = "DB master username stored in the secret."
  type        = string
}

variable "db_admin_database" {
  description = "Maintenance database used for CREATE/DROP DATABASE."
  type        = string
  default     = "postgres"
}
