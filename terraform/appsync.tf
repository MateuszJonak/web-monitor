
resource "random_pet" "appsync_api_name" {
  prefix    = "web_monitor_appsync"
  length   = 4
}

data "local_file" "schema" {
    filename = "${path.module}/schema.graphql"
}

resource "aws_appsync_graphql_api" "web_monitor_appsync" {
  authentication_type = "OPENID_CONNECT"
  name                = random_pet.appsync_api_name.id

  schema = data.local_file.schema.content

  log_config {
    cloudwatch_logs_role_arn  = aws_iam_role.web_monitor_appsync_exec.arn
    field_log_level            = "ALL"
    exclude_verbose_content   = false
  }

  openid_connect_config {
    issuer = "https://${var.auth0_domain}"
  }
}

resource "aws_cloudwatch_log_group" "web_monitor_appsync_log_group" {
  name = "/aws/appsync/${aws_appsync_graphql_api.web_monitor_appsync.id}"

  retention_in_days = 30
}

/**
  Role for appsync cron
*/
resource "aws_iam_role" "web_monitor_appsync_exec" {
  name = "web_monitor_appsync_exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "appsync.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "web_monitor_appsync_policy" {
  role       = aws_iam_role.web_monitor_appsync_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
}

resource "aws_iam_role_policy" "web_monitor_appsync_dynamodb_policy" {
  name = "web_monitor_appsync_dynamodb_policy"
  role = aws_iam_role.web_monitor_appsync_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:*"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_dynamodb_table.data.arn}",
          "${aws_dynamodb_table.data.arn}/*"
        ]
      },
    ]
  })
}

resource "aws_appsync_datasource" "web_monitor_appsync_datasource" {
  api_id           = aws_appsync_graphql_api.web_monitor_appsync.id
  name             = "web_monitor_appsync_datasource"
  service_role_arn = aws_iam_role.web_monitor_appsync_exec.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.data.name
  }
}

resource "aws_appsync_resolver" "offers_resolver" {
  api_id      = aws_appsync_graphql_api.web_monitor_appsync.id
  field        = "offers"
  type        = "Query"
  data_source = aws_appsync_datasource.web_monitor_appsync_datasource.name

  request_template = <<EOF
{
    "version": "2018-05-29",
    "operation" : "Scan"
}
EOF

  response_template = <<EOF
$utils.toJson($context.result.items)
EOF
}