include "root" {
  path   = find_in_parent_folders("root.hcl")
}

dependency "github_oidc" {
  config_path = "../github-oidc"
}

locals {
  github_org  = get_env("GITHUB_ORG", "your-github-org")
  github_repo = get_env("GITHUB_REPO", "eks-httpbin-deployment")

  root_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-role?version=6.2.1"
}

inputs = {
  name = "github-actions-eks-deploy"

  enable_github_oidc = true

  oidc_wildcard_subjects = [
    "${local.github_org}/${local.github_repo}:*"
  ]

  create_inline_policy = true
  inline_policy_permissions = {
    EKSManagement = {
      actions = [
        "eks:*",
        "ec2:*",
        "iam:*",
        "ssm:*",
        "autoscaling:*",
        "elasticloadbalancing:*",
        "logs:*",
        "kms:*"
      ]
      resources = ["*"]
    }
    TerraformState = {
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::terraform-state-${local.root_vars.locals.account_id}-${local.root_vars.locals.aws_region}",
        "arn:aws:s3:::terraform-state-${local.root_vars.locals.account_id}-${local.root_vars.locals.aws_region}/*"
      ]
    }
  }

  tags = {
    Environment = "dev"
    Purpose     = "GitHub Actions role for EKS deployment"
    Project     = "httpbin-deployment"
  }
}

