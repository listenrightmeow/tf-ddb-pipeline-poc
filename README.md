This POC is inspired by my work with @j-groeneveld and this [article](https://engineering.linkedin.com/distributed-systems/log-what-every-software-engineer-should-know-about-real-time-datas-unifying).

tl;dr: Scalable data architectures are hard. Keeping them digestible and organized is harder. Getting them to scale, good luck.

This POC introduces the concept of Terraform Workspaces. The Workspace utilized in this example is "production". When designing simplicity for CI/CD, your Workspace should model the same branch name that will be utilized for the build in your application pipeline.

In our example, we utilize `master` as our `production` equivalent branch.

## 💩 Requirements

1. TFENV is highly suggested (https://github.com/tfutils/tfenv), Terraform as an alternative
  `brew install terraform`
1. AWS CLI (link provided below)

## 🚀 Setup Instructions

1. Create AWS user with pragmatic access (https://console.aws.amazon.com/iam/home?region=us-west-1#/users)
1. Install & configure AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/install-macos.html#awscli-install-osx-pip, profile suggested)
1. Create S3 bucket for Terraform state storage (us-east-1, versioning, private, https://s3.console.aws.amazon.com/s3/home?region=us-east-1)
1. Create DynamoDB Table for Terraform region locking (us-east-1, pk: LockID, https://console.aws.amazon.com/dynamodb/home?region=us-east-1)
1. Create Terraform Workspace. Aim to replicate automation (CI/CD) branches (development, test, staging, production).
1. Configure backend/environments secrets files (`secrets/**/*.tfvars.example`) from step #1 (https://www.terraform.io/docs/backends/types/s3.html) and rename to `secrets/**/*.tfvars`.


## 🦄 Deployment

The terraform script will automatically create, and deploy to, your environment workspace.

In a simplified CI/CD pipeline, the workspace environment mapping would closely resemble:

```
'master'
|\
| * branch - development
| * branch - test
| * branch - qa
|/
```

1. `./scripts/terraform.sh -e<environment>` (e.g. `./scripts/terraform.sh -emaster`)

## 👓 Results

The above process will give your AWS environment a proper Workspace that can be designed after your CI/CD branching strategy.

This approach, by design, offers a low-level form of disaster recovery from a bare-metal/service layer. Further consideration will have to go into data migration and recovery patterns.
