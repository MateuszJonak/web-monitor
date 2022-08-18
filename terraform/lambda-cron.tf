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
}

resource "aws_cloudwatch_log_group" "cron" {
  name = "/aws/lambda/${aws_lambda_function.cron.function_name}"

  retention_in_days = 30
}

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
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.web_monitor_lambda_cron_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
