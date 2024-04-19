// get aws account id from --ext-str
// e.g., jsonnet --ext-str AWS_ACCOUNT_ID=123456789012 -e 'std.extVar("AWS_ACCOUNT_ID")'
local aws_account_id = std.extVar('AWS_ACCOUNT_ID');
local username = std.extVar('QUICKSIGHT_USERNAME');
local dashboard_definition = import 'dashboard-definition.json';

{
  AwsAccountId: aws_account_id,
  DashboardId: 'blog-glue-trigger-refresh-qs-spice-dashboard',
  Name: 'blog-glue-trigger-refresh-qs-spice',
  Permissions: [
    {
      Principal: 'arn:aws:quicksight:us-east-1:' + aws_account_id + ':user/default/' + username,
      Actions: [
        'quicksight:DescribeDashboard',
        'quicksight:ListDashboardVersions',
        'quicksight:UpdateDashboardPermissions',
        'quicksight:QueryDashboard',
        'quicksight:UpdateDashboard',
        'quicksight:DeleteDashboard',
        'quicksight:DescribeDashboardPermissions',
        'quicksight:UpdateDashboardPublishedVersion',
      ],
    },
  ],
  DashboardPublishOptions: {
    AdHocFilteringOption: {
      AvailabilityStatus: 'ENABLED',
    },
    ExportToCSVOption: {
      AvailabilityStatus: 'ENABLED',
    },
    SheetControlsOption: {
      VisibilityState: 'EXPANDED',
    },
    VisualPublishOptions: {
      ExportHiddenFieldsOption: {
        AvailabilityStatus: 'ENABLED',
      },
    },
  },
  Definition: dashboard_definition {
    DataSetIdentifierDeclarations: [
      {
        Identifier: 'blog-glue-trigger-refresh-qs-spice',
        DataSetArn: 'arn:aws:quicksight:ap-southeast-1:' + aws_account_id + ':dataset/blog-glue-trigger-refresh-qs-spice-dataset',
      },
    ],
  },
}
