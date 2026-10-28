# One-time setup of AWS remote state + GitHub OIDC. Uses local state; run manually, not from CI.
# Auth: `aws sso login` / AWS_PROFILE locally. No account IDs are stored in this repo.
terraform {
  required_version = ">= 1.10.0" # S3 native state locking (use_lockfile)

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# ---------------------------------------------------------------------------
# State bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------------------------
# GitHub Actions OIDC: CI assumes a role with short-lived tokens, no stored keys.
# ---------------------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only this repo, and only the listed GitHub environments, can assume the role.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for env in var.github_environments : "repo:${var.github_repo}:environment:${env}"]
    }
  }
}

resource "aws_iam_role" "terraform_ci" {
  name               = "terraform-ci"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

# LEARNING NOTE: AdministratorAccess is a shortcut for a sandbox account. Replace it with a
# scoped policy before using this role anywhere real (see ADR-0003 follow-ups).
resource "aws_iam_role_policy_attachment" "terraform_ci_admin" {
  count      = var.attach_admin_policy ? 1 : 0
  role       = aws_iam_role.terraform_ci.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
