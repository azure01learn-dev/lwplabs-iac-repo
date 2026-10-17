# lwplabs IaC Repo

This repository deploys a simple AWS infrastructure stack using reusable Terraform modules from the GitHub module repo.

## What this deploys

- VPC
- Public subnet
- Internet gateway
- Public route table
- Network ACL
- Security group
- 1 EC2 instance

## Prerequisites

Before running Terraform, make sure you have:

- Terraform installed
- AWS CLI configured with credentials
- Access to an AWS account

Check AWS login:

```bash
aws configure
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

## 1. Change to the repo folder

```bash
cd lwplabs-iac-repo
```

## 2. Create your tfvars file

Copy the example values into a real file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then edit `terraform.tfvars` with your own values:

```hcl
aws_region      = "us-east-1"
project_name    = "lwplabs"
environment     = "dev"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24"]
availability_zones = ["us-east-1a"]
instance_type   = "t3.micro"
```

## 3. Initialize Terraform

```bash
terraform init
```

## 4. Review the plan

```bash
terraform plan -var-file="terraform.tfvars"
```

## 5. Apply the infrastructure

```bash
terraform apply -var-file="terraform.tfvars"
```

When prompted, type:

```bash
yes
```

## 6. Destroy resources when finished

```bash
terraform destroy -var-file="terraform.tfvars"
```

## Notes

- The Terraform modules are pulled from GitHub using the `main` branch.
- The source is defined in the root module files using `git::https://github.com/olajidenurudeenrasaq-dotcom/AWS-Modules.git//<module>?ref=main`.
- Keep your `terraform.tfvars` file private and do not commit secrets to source control.
