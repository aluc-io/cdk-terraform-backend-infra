import { Stack, StackProps, App, RemovalPolicy } from '@aws-cdk/core'
import { Table, AttributeType } from '@aws-cdk/aws-dynamodb'

export default class DynamoDB extends Stack {
  constructor(app: App, id: string, props?: StackProps) {
    super(app, id, props)

    const tableName = process.env.TSB_DYNAMODB_TABLE_NAME
    if (!tableName) throw new Error('TSB_DYNAMODB_TABLE_NAME is required')

    const table = new Table(this, 'aluc-io-v3-terraform', {
      tableName: tableName,
      partitionKey: { name: 'LockID', type: AttributeType.STRING },
      removalPolicy: RemovalPolicy.RETAIN,
    })
  }
}
