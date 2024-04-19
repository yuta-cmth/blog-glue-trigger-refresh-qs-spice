// get aws account id from --ext-str
// e.g., jsonnet --ext-str AWS_ACCOUNT_ID=123456789012 -e 'std.extVar("AWS_ACCOUNT_ID")'
local aws_account_id = std.extVar('AWS_ACCOUNT_ID');
local username = std.extVar('QUICKSIGHT_USERNAME');
local analysis_definition = import 'analysis-definition.json';

{
  AwsAccountId: aws_account_id,
  AnalysisId: 'blog-glue-trigger-refresh-qs-spice-analysis',
  Name: 'blog-glue-trigger-refresh-qs-spice',
  Permissions: [
    {
      Principal: 'arn:aws:quicksight:us-east-1:' + aws_account_id + ':user/default/' + username,
      Actions: [
        'quicksight:RestoreAnalysis',
        'quicksight:UpdateAnalysisPermissions',
        'quicksight:DeleteAnalysis',
        'quicksight:DescribeAnalysisPermissions',
        'quicksight:QueryAnalysis',
        'quicksight:DescribeAnalysis',
        'quicksight:UpdateAnalysis',
      ],
    },
  ],
  Definition: analysis_definition {
    DataSetIdentifierDeclarations: [
      {
        Identifier: 'blog-glue-trigger-refresh-qs-spice',
        DataSetArn: 'arn:aws:quicksight:ap-southeast-1:' + aws_account_id + ':dataset/blog-glue-trigger-refresh-qs-spice-dataset',
      },
    ],
  },
}
