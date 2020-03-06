# cdk-terraform-backend-infra
This project for Terraform S3 backend with DynamoDB.

## Environments

```
export AWS_ACCESS_KEY_ID=AKXXXXXXXXXXXXXXXXUU
export AWS_SECRET_ACCESS_KEY=M4xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx6Y
export AWS_DEFAULT_REGION=ap-northeast-2
export CDK_DEPLOY_ACCOUNT=500000000002

export TSB_BUCKET_NAME=s3-bucket-name-you-want
export TSB_DYNAMODB_TABLE_NAME=dynamodb-table-name-you-want
```

## Useful commands
* `cdk deploy`      deploy this stack to your default AWS account/region
* `cdk diff`        compare deployed stack with current state
* `cdk synth`       emits the synthesized CloudFormation template
