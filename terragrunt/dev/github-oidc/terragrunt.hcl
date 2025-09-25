include "root" {
  path   = find_in_parent_folders("root.hcl")
}

locals {
  github_org  = get_env("GITHUB_ORG", "your-github-org")
  github_repo = get_env("GITHUB_REPO", "eks-httpbin-deployment")
}

terraform {
  source = "tfr:///terraform-aws-modules/iam/aws//modules/iam-oidc-provider?version=6.2.1"
}

inputs = {
  url = "https://token.actions.githubusercontent.com"

  tags = {
    Environment = "dev"
    Purpose     = "GitHub Actions OIDC for EKS deployment"
    Project     = "httpbin-deployment"
  }
}