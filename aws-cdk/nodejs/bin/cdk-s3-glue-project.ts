#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CdkS3GlueStack } from '../lib/cdk-s3-glue-stack';

const app = new cdk.App();
new CdkS3GlueStack(app, 'CdkS3GlueStack');
