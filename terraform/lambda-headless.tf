resource "random_pet" "lambda_headless_bucket_name" {
  prefix = "web-monitor-lambda-headless"
  length = 4
}

resource "aws_s3_bucket" "lambda_headless_bucket" {
  bucket = random_pet.lambda_headless_bucket_name.id

  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_headless_bucket_acl" {
  bucket = aws_s3_bucket.lambda_headless_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_headless_archive" {
  type = "zip"

  source_dir  = "${path.module}/../dist/apps/lambda-headless"
  output_path = "${path.module}/../dist/apps/lambda-headless.zip"
}

resource "aws_s3_object" "lambda_headless_s3_object" {
  bucket = aws_s3_bucket.lambda_headless_bucket.id

  key    = "lambda-headless.zip"
  source = data.archive_file.lambda_headless_archive.output_path

  etag   = filemd5(data.archive_file.lambda_headless_archive.output_path)
}

resource "aws_lambda_function" "lambda_headless" {
  function_name = "WebMonitorHeadless"

  s3_bucket = aws_s3_bucket.lambda_headless_bucket.id
  s3_key    = aws_s3_object.lambda_headless_s3_object.key

  runtime = "nodejs14.x"
  handler = "main.handler"
  
  source_code_hash = data.archive_file.lambda_headless_archive.output_base64sha256

  role = aws_iam_role.web_monitor_lambda_headless_exec.arn

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      DATA_TABLE_NAME = "${aws_dynamodb_table.data.name}"
    }
  }

  layers = [ "arn:aws:lambda:eu-central-1:764866452798:layer:chrome-aws-lambda:31" ]

  memory_size = 1024
  timeout = 40
}

resource "aws_cloudwatch_log_group" "lambda_headless_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_headless.function_name}"

  retention_in_days = 30
}

/**
  Policy for connections between lambda headless and dynamodb
*/
resource "aws_iam_role_policy" "lambda_headless_dynamodb_policy" {
  name = "lambda_headless_dynamodb_policy"
  role = aws_iam_role.web_monitor_lambda_headless_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_dynamodb_table.pub_sub.arn}",
          "${aws_dynamodb_table.pub_sub.arn}/*"
        ]
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
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

resource "aws_iam_role_policy" "lambda_headless_xray_policy" {
  name = "lambda_headless_xray_policy"
  role = aws_iam_role.web_monitor_lambda_headless_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
    ]
  })
}

/**
  Role for lambda headless
*/
resource "aws_iam_role" "web_monitor_lambda_headless_exec" {
  name = "serverless_web_monitor_lambda_headless"

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

resource "aws_iam_role_policy_attachment" "lambda_headless_policy" {
  role       = aws_iam_role.web_monitor_lambda_headless_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_event_source_mapping" "lambda_headless" {
  event_source_arn        = aws_dynamodb_table.pub_sub.stream_arn
  function_name           = aws_lambda_function.lambda_headless.arn
  starting_position       = "LATEST"
  batch_size              = 10
  maximum_retry_attempts  = 3
}