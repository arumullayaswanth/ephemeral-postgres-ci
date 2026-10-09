terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state in S3. The bucket and region are supplied at init time via
  # -backend-config (see the Terraform workflow), so the bucket name can live
  # in a GitHub variable instead of being hardcoded here.
  backend "s3" {
    key          = "ephemeral-postgres-ci/terraform.tfstate"
    encrypt      = true
    use_lockfile = true # S3-native state locking (no DynamoDB table needed)
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
