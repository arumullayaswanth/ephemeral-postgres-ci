locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  secret_name = "${var.environment}/${var.project_name}/db-admin"
}

# ---------------------------------------------------------------------------
# Auto-discover the default VPC and its subnets so no IDs are hardcoded.
# ---------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  vpc_id        = data.aws_vpc.default.id
  subnet_ids    = data.aws_subnets.default.ids
  ec2_subnet_id = local.subnet_ids[0]
  # Use up to two subnets (different AZs in the default VPC) for the DB group.
  db_subnet_ids = slice(local.subnet_ids, 0, min(2, length(local.subnet_ids)))
}

# ---------------------------------------------------------------------------
# Generate the DB master password (never stored in code or tfvars).
# Fed into RDS and the Secrets Manager secret so they stay in sync.
# ---------------------------------------------------------------------------

resource "random_password" "db" {
  length           = var.db_password_length
  special          = true
  override_special = "!#%*-_=+"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

# ---------------------------------------------------------------------------
# EC2 client that connects to RDS (the DB client / self-hosted runner host).
# ---------------------------------------------------------------------------

module "ec2_client" {
  source = "./modules/ec2_client"

  name                    = var.project_name
  vpc_id                  = local.vpc_id
  subnet_id               = local.ec2_subnet_id
  instance_type           = var.instance_type
  ami_id                  = var.ami_id
  key_name                = var.key_name
  associate_public_ip     = var.associate_public_ip
  create_instance_profile = var.ec2_create_instance_profile
  iam_instance_profile    = var.ec2_instance_profile
  allow_ssh_cidrs         = var.allow_ssh_cidrs

  # Install DB tools and (optionally) seed demo data on first boot.
  region      = var.aws_region
  secret_name = local.secret_name
  seed_data   = var.seed_data
  # Concatenate all migrations (in filename order) into the first-boot seed SQL.
  seed_sql = join("\n", [
    for f in sort(fileset("${path.module}/../migrations", "*.sql")) :
    file("${path.module}/../migrations/${f}")
  ])

  # Allow reading the DB secret, and make the instance boot after the secret
  # (and its value) exist so seeding can succeed.
  secret_arn      = module.secrets.secret_arn
  depends_on_arns = [module.secrets.secret_version_id]

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# RDS PostgreSQL instance, reachable only from the EC2 client's security group.
# ---------------------------------------------------------------------------

module "rds" {
  source = "./modules/rds"

  name       = var.project_name
  vpc_id     = local.vpc_id
  subnet_ids = local.db_subnet_ids

  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  db_name         = var.db_name
  master_username = var.db_master_username
  master_password = random_password.db.result

  multi_az            = var.db_multi_az
  deletion_protection = var.db_deletion_protection
  skip_final_snapshot = var.db_skip_final_snapshot

  # Only the EC2 client may connect to the database.
  allowed_security_group_ids = [module.ec2_client.security_group_id]

  tags = local.common_tags
}

# ---------------------------------------------------------------------------
# Store DB connection details in AWS Secrets Manager (with generated password).
# Written after RDS exists so the real endpoint is captured.
# ---------------------------------------------------------------------------

module "secrets" {
  source = "./modules/secrets"

  secret_name          = local.secret_name
  recovery_window_days = var.secret_recovery_window_days

  db_host           = module.rds.address
  db_port           = module.rds.port
  db_username       = var.db_master_username
  db_password       = random_password.db.result
  db_admin_database = var.db_name

  tags = local.common_tags
}
