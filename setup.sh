#!/bin/bash
set -e # fail if any stage has exit code with some logical exceptions
set -o pipefail # exit if fail code in pipe passing
set -u # fail if variables unset

# Create S3 bucket for state
BUCKET="terraform-state-${AWS_ACCOUNT_ID}-${AWS_REGION}"
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
    echo "Bucket exists"
else
    aws s3 mb "s3://$BUCKET" --region "${AWS_REGION}"
fi

# Deploy OIDC and role
cd terragrunt/dev/github-oidc
terragrunt apply --non-interactive --auto-approve

cd ../github-role
terragrunt apply --non-interactive --auto-approve

# Output role ARN for github secret
echo "AWS_ROLE_ARN=$(terragrunt output -raw github_actions_role_arn)"