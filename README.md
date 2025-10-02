# EKS Deployment Example

A complete infrastructure-as-code example for deploying a Kubernetes application on AWS EKS using Terragrunt, Terraform, and GitHub Actions.

## Overview

This project demonstrates how to:
- Deploy AWS VPC and EKS cluster using Terragrunt and Terraform modules
- Set up GitHub Actions OIDC authentication for AWS
- Deploy applications to EKS using Helmfile
- Run automated smoke tests against the deployed application
- Clean up resources with automated destroy workflows

## Architecture

```
AWS Account
├── VPC (terraform-aws-modules/vpc)
│   ├── Public/Private Subnets
│   └── NAT Gateways
├── EKS Cluster (terraform-aws-modules/eks)
│   ├── Managed Node Groups
│   ├── OIDC Provider
│   └── Cluster Access Entries
├── GitHub OIDC Provider
└── GitHub Actions IAM Role
```

## Project Structure

```
.
├── .github/workflows/        # GitHub Actions workflows
│   ├── deploy.yml           # Deploy infrastructure and app
│   └── destroy.yml          # Destroy infrastructure
├── terragrunt/              # Terragrunt configurations
│   └── dev/
│       ├── vpc/             # VPC configuration
│       ├── eks/             # EKS cluster configuration
│       ├── github-oidc/     # GitHub OIDC provider
│       └── github-role/     # GitHub Actions IAM role
├── helmfile/                # Kubernetes application deployment
│   ├── helmfile.yaml        # Application definitions
│   └── values/              # Helm values
└── root.hcl                 # Global Terragrunt configuration
```

## Components

### Infrastructure (Terragrunt/Terraform)

1. **VPC**: Creates network infrastructure with public/private subnets
2. **EKS**: Managed Kubernetes cluster with worker nodes
3. **GitHub OIDC**: Enables GitHub Actions to authenticate with AWS
4. **GitHub Role**: IAM role with permissions for deployment

### Application (Helmfile)

- **HTTPBin**: Test application deployed to demonstrate the setup
- **Ingress**: AWS Load Balancer with Nginx Ingress and cert-manger

### CI/CD (GitHub Actions)

- **Deploy Workflow**: Provisions infrastructure and deploys applications
- **Destroy Workflow**: Clean up all resources
- **Smoke Tests**: Validates application endpoints

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **GitHub Repository** with secrets configured:
   - `AWS_ACCOUNT_ID`: Your AWS account ID
   - `AWS_ROLE_ARN`: GitHub Actions role ARN (created by this project)
   - `CLUSTER_NAME`: EKS cluster name
3. **GitHub Variables**:
   - `AWS_REGION`: Target AWS region (e.g., `eu-west-2`)

## Setup Instructions

### 1. Configure Environment Variables

Set these environment variables before running Terragrunt:

```bash
export GITHUB_ORG="your-github-username"
export GITHUB_REPO="your-repo-name"
export AWS_REGION="eu-west-2"
export AWS_ACCOUNT_ID=aws_account_numebr
export CLUSTER_NAME="httpbin-eks

```

### 2. Configure Github role and oicd

```bash
docker-compose run terragrunt
##
bash setup.sh
```

### 3. Deploy Infrastructure

#### Option A: GitHub Actions

1. Push code to `main` branch or trigger workflow manually
2. GitHub Actions will automatically:
   - Deploy VPC and EKS cluster
   - Deploy HTTPBin application
   - Run smoke tests

#### Option B: Local Deployment

```bash
docker-compose run terragrunt
cd terragrunt/dev/vpc
terragrunt apply

cd ../eks
terragrunt apply

# Deploy application
cd ../../../helmfile
helmfile sync
```

### 4. Access application

- Change to your host in ingress `helmfile/values/httpbin.yaml`
- add DNS entry

### Destroy Workflow (`destroy.yml`)

- **Manual trigger only** with confirmation required
- Type "DESTROY" to confirm resource deletion
- Destroys EKS cluster first, then VPC