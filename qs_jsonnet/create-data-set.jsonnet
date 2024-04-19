// get aws account id from --ext-str
// e.g., jsonnet --ext-str AWS_ACCOUNT_ID=123456789012 -e 'std.extVar("AWS_ACCOUNT_ID")'
local aws_account_id = std.extVar('AWS_ACCOUNT_ID');
local username = std.extVar('QUICKSIGHT_USERNAME');
local data_set_id = std.extVar('DATA_SET_ID');

{
  AwsAccountId: aws_account_id,
  DataSetId: data_set_id,
  Name: 'blog-glue-trigger-refresh-qs-spice',
  PhysicalTableMap: {
    'blog-glue-trigger-refresh-qs-spice-physical-table': {
      CustomSql: {
        DataSourceArn: 'arn:aws:quicksight:ap-southeast-1:' + aws_account_id + ':datasource/blog-glue-trigger-refresh-qs-spice-data-source',
        Name: 'blog_glue_trigger_refresh_qs_spice',
        SqlQuery: 'SELECT * FROM "blog_glue_db"."data"',
        Columns: [
          {
            Name: 'metric1',
            Type: 'INTEGER',
          },
          {
            Name: 'dimension1',
            Type: 'STRING',
          },
          {
            Name: 'timestamp',
            Type: 'DATETIME',
          },
        ],
      },
    },
  },
  LogicalTableMap: {
    '4464601c-5717-47aa-b868-72a91b5a0ee5': {
      Alias: 'blog_glue_trigger_refresh_qs_spice_logical_table',
      DataTransforms: [
        {
          ProjectOperation: {
            ProjectedColumns: [
              'timestamp',
              'metric1',
              'dimension1',
            ],
          },
        },
      ],
      Source: {
        PhysicalTableId: 'blog-glue-trigger-refresh-qs-spice-physical-table',
      },
    },
  },
  ImportMode: 'SPICE',
  Permissions: [
    {
      Principal: 'arn:aws:quicksight:us-east-1:' + aws_account_id + ':user/default/' + username,
      Actions: [
        'quicksight:DeleteDataSet',
        'quicksight:ListIngestions',
        'quicksight:UpdateDataSetPermissions',
        'quicksight:CancelIngestion',
        'quicksight:DescribeDataSetPermissions',
        'quicksight:UpdateDataSet',
        'quicksight:PassDataSet',
        'quicksight:DescribeDataSet',
        'quicksight:DescribeIngestion',
        'quicksight:CreateIngestion',
      ],
    },
  ],
}
