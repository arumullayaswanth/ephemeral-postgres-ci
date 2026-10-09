# Create the Secrets Manager secret (container). The value is written by the
# aws_secretsmanager_secret_version resource below.
resource "aws_secretsmanager_secret" "db" {
  name                    = var.secret_name
  description             = "DB credentials for ephemeral CI databases."
  recovery_window_in_days = var.recovery_window_days
  tags                    = var.tags
}

# Store the full connection details as JSON. The endpoint is supplied by the
# caller after the RDS instance exists, avoiding a dependency cycle.
resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    PGHOST     = var.db_host
    PGPORT     = tostring(var.db_port)
    PGUSER     = var.db_username
    PGPASSWORD = var.db_password
    PGADMINDB  = var.db_admin_database
  })
}
