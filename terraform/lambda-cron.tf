resource "random_pet" "lambda_cron_bucket_name" {
  prefix = "web-monitor-lambda-cron"
  length = 4
}

resource "aws_s3_bucket" "lambda_cron_bucket" {
  bucket = random_pet.lambda_cron_bucket_name.id

  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_cron_bucket_acl" {
  bucket = aws_s3_bucket.lambda_cron_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_cron" {
  type = "zip"

  source_dir  = "${path.module}/../dist/apps/lambda-cron"
  output_path = "${path.module}/../dist/apps/lambda-cron.zip"
}

resource "aws_s3_object" "lambda_cron" {
  bucket = aws_s3_bucket.lambda_cron_bucket.id

  key    = "lambda-cron.zip"
  source = data.archive_file.lambda_cron.output_path

  etag   = filemd5(data.archive_file.lambda_cron.output_path)
}

resource "aws_lambda_function" "cron" {
  function_name = "WebMonitorCRON"

  s3_bucket = aws_s3_bucket.lambda_cron_bucket.id
  s3_key    = aws_s3_object.lambda_cron.key

  runtime = "nodejs14.x"
  handler = "main.handler"
  
  source_code_hash = data.archive_file.lambda_cron.output_base64sha256

  role = aws_iam_role.web_monitor_lambda_cron_exec.arn

  environment {
    variables = {
      PUB_SUB_TABLE_NAME = "${aws_dynamodb_table.pub_sub.name}",
      S3_CONFIG_BUCKET_NAME = "${aws_s3_bucket.config_bucket.id}"
      S3_CONFIG_KEY = "${var.config_file_name}"
    }
  }
}

resource "aws_cloudwatch_log_group" "cron" {
  name = "/aws/lambda/${aws_lambda_function.cron.function_name}"

  retention_in_days = 30
}

/**
  Policy for connections between lambda cron and dynamodb
*/
resource "aws_iam_role_policy" "lambda_cron_dynamodb_policy" {
  name = "lambda_cron_dynamodb_policy"
  role = aws_iam_role.web_monitor_lambda_cron_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
        ]
        Effect   = "Allow"
        Resource = "${aws_dynamodb_table.pub_sub.arn}"
      },
    ]
  })
}

/**
  Policy for connections between lambda cron and s3 config bucket
*/
resource "aws_iam_role_policy" "lambda_cron_s3_config_policy" {
  name = "lambda_cron_s3_config_policy"
  role = aws_iam_role.web_monitor_lambda_cron_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.config_bucket.arn}",
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      },
    ]
  })
}

/**
  Role for lambda cron
*/
resource "aws_iam_role" "web_monitor_lambda_cron_exec" {
  name = "serverless_web_monitor_lambda_cron"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.web_monitor_lambda_cron_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "random_pet" "lambda_cron_event_rule_name" {
  prefix = "web-monitor-lambda-cron-event"
  length = 2
}

resource "aws_cloudwatch_event_rule" "lambda_cron_cloudwatch_event_rule" {
  name                = random_pet.lambda_cron_event_rule_name.id
  description         = "Fires every 12 hours"
  schedule_expression = "rate(12 hours)"
}

resource "aws_cloudwatch_event_target" "lambda_cron_cloudwatch_event_target" {
  rule      = aws_cloudwatch_event_rule.lambda_cron_cloudwatch_event_rule.name
  target_id = "lambda"
  arn       = aws_lambda_function.cron.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_cron" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cron.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_cron_cloudwatch_event_rule.arn
}