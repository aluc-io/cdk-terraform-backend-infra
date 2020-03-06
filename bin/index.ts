#!/usr/bin/env node
import * as cdk from '@aws-cdk/core';
import S3Bucket from '../lib/s3-bucket';
import DynamoDB from '../lib/dynamo-db';

const app = new cdk.App();
new S3Bucket(app, 'StackS3Bucket');
new DynamoDB(app, 'StackDynamoDB');
