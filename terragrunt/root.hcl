# Root terragrunt configuration
locals {
  aws_region   = get_env("AWS_REGION", "eu-west-2")
  account_id   = get_env("AWS_ACCOUNT_ID", "")
  environment  = get_env("ENVIRONMENT", "dev")
  cluster_name = get_env("CLUSTER_NAME", "httpbin-eks")

  azs         = ["${local.aws_region}a", "${local.aws_region}b", "${local.aws_region}c"]

  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = local.environment
    Project     = "httpbin-deployment"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"

  default_tags {
    tags = {
      Environment = "${local.environment}"
      ManagedBy   = "Terragrunt"
      Project     = "httpbin-deployment"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket  = "terraform-state-${local.account_id}-${local.aws_region}"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = local.aws_region
    encrypt = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}