# cdk-terraform-website-infra
This project is for creation belows:
- S3 bucket and DynamoDB for terraform s3 backend
- S3 bucket for static web site contents
- CloudFront for website CDN
- Route53 A Record for connecting CloudFront using domain

## Environments

```
# .envrc
export AWS_ACCESS_KEY_ID=AKXXXXXXXXXXXXXXXXUU
export AWS_SECRET_ACCESS_KEY=M4xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6Y
export AWS_DEFAULT_REGION=us-east-1
export CDK_DEPLOY_ACCOUNT=500000000002  # Your AWS Accout

# TSB is Terraform S3 Backend
export TSB_BUCKET_NAME=s3-bucket-name-you-want
export TSB_DYNAMODB_TABLE_NAME=dynamodb-table-name-you-want
export TF_VAR_BUCKET_NAME=<for website contents>
export TF_VAR_BUCKET_NAME_FOR_LOG=<for CloudFront logs>
export TF_VAR_ROUTE53_ZONE_NAME=example.com
export TF_VAR_DOMAIN=blog.example.com
```

```
# backend.hcl
bucket  = "<value of $TSB_BUCKET_NAME>"
key     = "state"
region  = "ap-northeast-2"
encrypt = true
```

## Terraform init and apply

```
# deploy this stack to your default AWS account/region
$ cdk deploy      

$ terraform workspace show
default

$ terraform init -backend-config=backend.hcl
$ terraform apply
```

## Upload static site content

Example:
```
$ aws s3 cp --recursive public/ s3://$TF_VAR_BUCKET_NAME/default/
```

