resource "random_pet" "lambda_scraper_bucket_name" {
  prefix = "web-monitor-lambda-scraper"
  length = 4
}

resource "aws_s3_bucket" "lambda_scraper_bucket" {
  bucket = random_pet.lambda_scraper_bucket_name.id

  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_scraper_bucket_acl" {
  bucket = aws_s3_bucket.lambda_scraper_bucket.id
  acl    = "private"
}

data "archive_file" "lambda_scraper_archive" {
  type = "zip"

  source_dir  = "${path.module}/../dist/apps/lambda-scraper"
  output_path = "${path.module}/../dist/apps/lambda-scraper.zip"
}

resource "aws_s3_object" "lambda_scraper_s3_object" {
  bucket = aws_s3_bucket.lambda_scraper_bucket.id

  key    = "lambda-scraper.zip"
  source = data.archive_file.lambda_scraper_archive.output_path

  etag   = filemd5(data.archive_file.lambda_scraper_archive.output_path)
}

resource "aws_lambda_function" "lambda_scraper" {
  function_name = "WebMonitorScraper"

  s3_bucket = aws_s3_bucket.lambda_scraper_bucket.id
  s3_key    = aws_s3_object.lambda_scraper_s3_object.key

  runtime = "nodejs14.x"
  handler = "main.handler"
  
  source_code_hash = data.archive_file.lambda_scraper_archive.output_base64sha256

  role = aws_iam_role.web_monitor_lambda_scraper_exec.arn

  tracing_config {
    mode = "Active"
  }

  environment {
    variables = {
      DATA_TABLE_NAME = "${aws_dynamodb_table.data.name}"
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_scraper_log_group" {
  name = "/aws/lambda/${aws_lambda_function.lambda_scraper.function_name}"

  retention_in_days = 30
}

/**
  Policy for connections between lambda scraper and dynamodb
*/
resource "aws_iam_role_policy" "lambda_scraper_dynamodb_policy" {
  name = "lambda_scraper_dynamodb_policy"
  role = aws_iam_role.web_monitor_lambda_scraper_exec.id

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
    ]
  })
}

resource "aws_iam_role_policy" "lambda_scraper_xray_policy" {
  name = "lambda_scraper_xray_policy"
  role = aws_iam_role.web_monitor_lambda_scraper_exec.id

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
  Role for lambda scraper
*/
resource "aws_iam_role" "web_monitor_lambda_scraper_exec" {
  name = "serverless_web_monitor_lambda_scraper"

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

resource "aws_iam_role_policy_attachment" "lambda_scraper_policy" {
  role       = aws_iam_role.web_monitor_lambda_scraper_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_event_source_mapping" "lambda_scraper" {
  event_source_arn  = aws_dynamodb_table.pub_sub.stream_arn
  function_name     = aws_lambda_function.lambda_scraper.arn
  starting_position = "LATEST"
}