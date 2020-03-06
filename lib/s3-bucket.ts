import { App, Stack, StackProps, RemovalPolicy } from '@aws-cdk/core'
import { Bucket, BucketEncryption } from '@aws-cdk/aws-s3'
import { PolicyStatement, PolicyStatementProps, Effect } from '@aws-cdk/aws-iam'

export default class S3Bucket extends Stack {
  constructor(app: App, id: string, props?: StackProps) {
    super(app, id, props)

    const bucketName = process.env.TSB_BUCKET_NAME
    if (!bucketName) throw new Error('TSB_BUCKET_NAME is required')

    const bucket = new Bucket(this, bucketName, {
      encryption: BucketEncryption.KMS_MANAGED,
      bucketName: bucketName,
      removalPolicy: RemovalPolicy.RETAIN,
      versioned: true,
    })
  }
}
