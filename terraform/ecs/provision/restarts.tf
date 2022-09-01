
resource "aws_sns_topic_subscription" "solr_memory_lambda_target" {
  topic_arn = aws_sns_topic.solr_memory_updates.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.solr_restarts.arn
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_solr_restarts"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "lambda_operations" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_operations.arn
}

resource "aws_iam_policy" "lambda_operations" {
  name        = "solr-${local.lb_name}-lambda_operations"
  path        = "/"
  description = "IAM policy for logging/ecs-restarts from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda-restarts" {
  name              = "/aws/lambda/solr-${local.lb_name}-restarts"
  retention_in_days = 14
}

data "aws_secretsmanager_secret" "slackNotificationUrl" {
  count = var.slackNotification ? 1 : 0
  name = "slackSolrEventNotificationUrl"
}

data "aws_secretsmanager_secret_version" "slackNotificationUrl" {
  count = var.slackNotification ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.slackNotificationUrl[0].id
}

resource "local_file" "app" {
  count = var.slackNotification ? 1 : 0
  content  = replace(file("${path.module}/app_template.py"), "<slack-notification-url>", jsondecode(data.aws_secretsmanager_secret_version.slackNotificationUrl[0].secret_string)["slackNotificationUrl"])
  filename = "${path.module}/app.py"
}

resource "local_file" "app_no_slack" {
  count = var.slackNotification == false ? 1 : 0
  content  = replace(file("${path.module}/app_template.py"), "notifySlack(message_json, service_dimensions['ClusterName'], service_dimensions['ServiceName'])", "")
  filename = "${path.module}/app.py"
}

data "archive_file" "solr-restart-script" {
  type        = "zip"
  source_file = "${path.module}/app.py"
  output_path = "${path.module}/app.zip"

  depends_on = [
    local_file.app,
    local_file.app_no_slack
  ]
}

resource "aws_lambda_function" "solr_restarts" {
  function_name = "solr-${local.lb_name}-restarts"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.9"
  filename      = "app.zip"
  handler       = "app.handler"

  package_type = "Zip"
  depends_on = [
    data.archive_file.solr-restart-script
  ]
}
