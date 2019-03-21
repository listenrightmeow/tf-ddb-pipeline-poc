## 👓 Requirements 👓

1. Terraform
  `brew install terraform`
1. AWS CLI (link provided below)
1. TFENV is highly suggested (https://github.com/tfutils/tfenv)

## 🚀 Setup Instructions

1. Create AWS user with pragmatic access (https://console.aws.amazon.com/iam/home?region=us-west-1#/users)
1. Install & configure AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip, profile suggested)
1. Create S3 bucket for Terraform state storage (us-east-1, versioning, private, https://s3.console.aws.amazon.com/s3/home?region=us-east-1)
1. Create DynamoDB Table for Terraform region locking (us-east-1, pk: LockID, https://console.aws.amazon.com/dynamodb/home?region=us-east-1)
1. Create Terraform Workspace. Aim to replicate automation (CI/CD) branches (development, test, staging, production).
