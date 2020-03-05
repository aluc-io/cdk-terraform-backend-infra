#!/usr/bin/env node
import * as cdk from '@aws-cdk/core';
import S3Bucket from '../lib/s3-bucket';

const app = new cdk.App();
new S3Bucket(app, 'StackS3Bucket');
