#!/usr/bin/env node
import "source-map-support/register";
import * as cdk from "aws-cdk-lib";
import { BlogGlueTriggerStack } from "../lib/blog-glue-trigger-stack";

const app = new cdk.App();
new BlogGlueTriggerStack(app, "BlogGlueTriggerStack", {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION,
  },
  QS_DATA_SET_IDS: process.env.QS_DATA_SET_ID || "",
});
