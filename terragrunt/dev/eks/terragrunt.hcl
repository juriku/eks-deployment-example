include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  root_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}


dependency "vpc" {
  config_path = "../vpc"
}

dependency "github_role" {
  config_path = "../github-role"
}

terraform {
  source = "tfr:///terraform-aws-modules/eks/aws?version=21.3.1"
}

inputs = {
  name    = local.root_vars.locals.cluster_name
  kubernetes_version = "1.33"

  vpc_id                   = dependency.vpc.outputs.vpc_id
  subnet_ids               = dependency.vpc.outputs.private_subnets

  endpoint_public_access = true
  endpoint_private_access = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # enable_cluster_creator_admin_permissions = true

  access_entries = {
    github_actions = {
      kubernetes_groups = []
      principal_arn     = dependency.github_role.outputs.github_actions_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 1
      max_size     = 3

      instance_types = ["t2.small"]
      capacity_type  = "ON_DEMAND"

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        role = "general"
      }

      disk_size = 20
    }
  }

  tags = local.root_vars.locals.tags
}