# Latest Amazon Linux 2023 AMI, used when no ami_id is supplied.
data "aws_ami" "al2023" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security group for the EC2 client. This SG is the source allowed to reach RDS.
resource "aws_security_group" "client" {
  name        = "${var.name}-client"
  description = "DB client EC2 instance security group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-client" })
}


resource "aws_vpc_security_group_ingress_rule" "ssh" {
  for_each = toset(var.allow_ssh_cidrs)

  security_group_id = aws_security_group.client.id
  description       = "SSH access"
  cidr_ipv4         = each.value
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# Allow all egress so the client can reach RDS, package repos, and SSM.
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.client.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Dependency anchor: changes when upstream dependencies (the secret) are ready,
# forcing the instance to be created after them.
resource "terraform_data" "deps" {
  input = var.depends_on_arns
}

resource "aws_instance" "client" {
  ami                         = var.ami_id != null ? var.ami_id : data.aws_ami.al2023[0].id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.client.id]
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  iam_instance_profile        = local.instance_profile_name

  depends_on = [terraform_data.deps]

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    region          = var.region
    secret_name     = var.secret_name
    seed_data       = var.seed_data
    seed_sql        = var.seed_sql
    register_runner = var.register_runner
    github_owner    = var.github_owner
    github_repo     = var.github_repo
    runner_pat      = var.runner_pat
    runner_name     = var.runner_name
    runner_version  = var.runner_version
  })

  metadata_options {
    http_tokens   = "required" # enforce IMDSv2
    http_endpoint = "enabled"
  }

  root_block_device {
    encrypted = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = merge(var.tags, { Name = "${var.name}-client" })
}
