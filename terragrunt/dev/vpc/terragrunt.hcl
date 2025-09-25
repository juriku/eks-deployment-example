include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  root_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "tfr:///terraform-aws-modules/vpc/aws?version=6.2.0"
}

inputs = {
  name = "httpbin-vpc-${local.root_vars.locals.environment}"
  cidr = local.root_vars.locals.vpc_cidr

  azs             = local.root_vars.locals.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = 1
    "kubernetes.io/cluster/${local.root_vars.locals.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = 1
    "kubernetes.io/cluster/${local.root_vars.locals.cluster_name}" = "shared"
  }

  tags = local.root_vars.locals.tags
}
