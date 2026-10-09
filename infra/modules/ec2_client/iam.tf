# IAM role and instance profile for the EC2 client, created when
# create_instance_profile = true. Grants SSM access (for Session Manager) and
# read access to the DB secret (for seeding / connecting).

data "aws_iam_policy_document" "assume" {
  count = var.create_instance_profile ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "client" {
  count              = var.create_instance_profile ? 1 : 0
  name               = "${var.name}-client"
  assume_role_policy = data.aws_iam_policy_document.assume[0].json
  tags               = var.tags
}

# Managed policy that enables SSM Session Manager.
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.create_instance_profile ? 1 : 0
  role       = aws_iam_role.client[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Least-privilege read of the DB secret.
data "aws_iam_policy_document" "secret_read" {
  count = var.create_instance_profile && var.attach_secret_policy ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.secret_arn]
  }
}

resource "aws_iam_role_policy" "secret_read" {
  count  = var.create_instance_profile && var.attach_secret_policy ? 1 : 0
  name   = "${var.name}-read-db-secret"
  role   = aws_iam_role.client[0].id
  policy = data.aws_iam_policy_document.secret_read[0].json
}

resource "aws_iam_instance_profile" "client" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.name}-client"
  role  = aws_iam_role.client[0].name
  tags  = var.tags
}

locals {
  # Prefer the profile created here; fall back to a caller-supplied one.
  instance_profile_name = var.create_instance_profile ? aws_iam_instance_profile.client[0].name : var.iam_instance_profile
}
