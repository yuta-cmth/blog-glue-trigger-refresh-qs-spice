// get aws account id from --ext-str
// e.g., jsonnet --ext-str AWS_ACCOUNT_ID=123456789012 -e 'std.extVar("AWS_ACCOUNT_ID")'
local aws_account_id = std.extVar('AWS_ACCOUNT_ID');
local username = std.extVar('QUICKSIGHT_USERNAME');
local athena_work_group = std.extVar('ATHENA_WORKGROUP');

{
  AwsAccountId: aws_account_id,
  DataSourceId: 'blog-glue-trigger-refresh-qs-spice-data-source',
  Name: 'blog-glue-trigger-refresh-qs-spice',
  Type: 'ATHENA',
  DataSourceParameters: {
    AthenaParameters: {
      WorkGroup: athena_work_group,
    },
  },
  Permissions: [
    {
      Principal: 'arn:aws:quicksight:us-east-1:' + aws_account_id + ':user/default/' + username,
      Actions: [
        'quicksight:PassDataSource',
        'quicksight:DescribeDataSourcePermissions',
        'quicksight:UpdateDataSource',
        'quicksight:UpdateDataSourcePermissions',
        'quicksight:DescribeDataSource',
        'quicksight:DeleteDataSource',
      ],
    },
  ],
}
