import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
import * as s3 from "aws-cdk-lib/aws-s3";
import * as glue from "aws-cdk-lib/aws-glue";
import * as events from "aws-cdk-lib/aws-events";
import * as targets from "aws-cdk-lib/aws-events-targets";
import * as lambda from "aws-cdk-lib/aws-lambda";
import * as iam from "aws-cdk-lib/aws-iam";
import * as logs from "aws-cdk-lib/aws-logs";
import * as athena from "aws-cdk-lib/aws-athena";

interface BlogGlueTriggerStackProps extends cdk.StackProps {
  QS_DATA_SET_IDS: string; // Comma-separated data set IDs
}

export class BlogGlueTriggerStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: BlogGlueTriggerStackProps) {
    super(scope, id, props);

    // Create S3 bucket
    const bucket = new s3.Bucket(this, "BlogGlueCrawlerBucket", {
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    });

    // Attached to the Glue Crawler Role to crawl the S3 bucket
    const crawlerRole = new iam.Role(this, "BlogGlueCrawlerRole", {
      assumedBy: new iam.ServicePrincipal("glue.amazonaws.com"),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName(
          "service-role/AWSGlueServiceRole"
        ),
      ],
      inlinePolicies: {
        glueCrawlerPolicy: new iam.PolicyDocument({
          statements: [
            new iam.PolicyStatement({
              actions: ["s3:GetObject", "s3:PutObject"],
              resources: [`${bucket.bucketArn}/data/*`],
            }),
          ],
        }),
      },
    });

    const databaseName = "blog_glue_db";
    // Create Glue Database
    new glue.CfnDatabase(this, "BlogGlueDatabase", {
      databaseInput: {
        name: databaseName,
        description: "Blog Glue Database",
      },
      // CatalogId is the "AWS account ID for the account in which to create the catalog object".
      // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-glue-database.html
      catalogId: this.account,
    });

    // Create Glue Crawler
    const crawler = new glue.CfnCrawler(this, "BlogGlueCrawler", {
      name: "blog-glue-trigger-crawler",
      role: crawlerRole.roleArn,
      databaseName,
      targets: {
        s3Targets: [
          {
            path: `s3://${bucket.bucketName}/data`,
          },
        ],
      },
    });

    const workGroup = new athena.CfnWorkGroup(this, "BlogGlueWorkGroup", {
      name: "blog_glue_work_group",
      description: "Blog Glue Work Group",
      state: "ENABLED",
      recursiveDeleteOption: true,
      workGroupConfiguration: {
        resultConfiguration: {
          outputLocation: `s3://${bucket.bucketName}/query-results/`,
        },
      },
    });

    // Create EventBridge Rule
    const rule = new events.Rule(this, "BlogGlueCrawlerSucceededRule", {
      eventPattern: {
        source: ["aws.glue"],
        detailType: ["Glue Crawler State Change"],
        detail: {
          crawlerName: [crawler.name],
          state: ["Succeeded"],
        },
      },
    });

    const logGroupForLambda = new logs.LogGroup(
      this,
      "BlogGlueCrawlerEventHandlerLogGroup",
      {
        logGroupName: `/aws/lambda/blog-glue-crawler-event-handler`,
        removalPolicy: cdk.RemovalPolicy.DESTROY,
      }
    );

    // Create Lambda function
    const lambdaFunction = new lambda.Function(
      this,
      "BlogGlueCrawlerEventHandler",
      {
        runtime: lambda.Runtime.PYTHON_3_12,
        handler: "main.lambda_handler",
        code: lambda.Code.fromAsset(
          "codes/lambda/blog_glue_crawler_success_handler"
        ),
        environment: {
          APP_GLUE_CRAWLER_NAME: crawler.name as string,
          APP_QS_DATA_SET_IDS: props.QS_DATA_SET_IDS,
        },
        logGroup: logGroupForLambda,
      }
    );
    // Allow creating ingestion in QuickSight.
    lambdaFunction.addToRolePolicy(
      new iam.PolicyStatement({
        actions: [
          "quicksight:CreateIngestion",
          "quicksight:UpdateDataSet",
          "quicksight:DescribeDataSet",
        ],
        // any resource
        resources: ["*"],
      })
    );

    // Add EventBridge Rule as a target for Lambda function
    rule.addTarget(new targets.LambdaFunction(lambdaFunction));

    // Output bucket name, crawler name
    new cdk.CfnOutput(this, "BlogGlueCrawlerBucketName", {
      value: bucket.bucketName,
    });
    new cdk.CfnOutput(this, "BlogGlueCrawlerName", {
      value: crawler.name as string,
    });
    new cdk.CfnOutput(this, "BlogGlueCrawlerEventHandlerLogGroupName", {
      value: logGroupForLambda.logGroupName,
    });
    new cdk.CfnOutput(this, "BlogGlueAthenaWorkGroupName", {
      value: workGroup.name as string,
    });
  }
}
