# Output value definitions

output "lambda_cron_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_cron_bucket.id
}

output "lambda_cron_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.cron.function_name
}

output "lambda_headless_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_headless_bucket.id
}

output "lambda_headless_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.lambda_headless.function_name
}

output "dynamodb_pub_sub_table_name" {
  description = "Name of the PubSub DynamoDB table"
  value       = aws_dynamodb_table.pub_sub.name
}

output "dynamodb_pub_sub_table_arn" {
  description = "ARN of the PubSub DynamoDB table"
  value       = aws_dynamodb_table.pub_sub.arn
}

output "dynamodb_data_table_name" {
  description = "Name of the Data DynamoDB table"
  value       = aws_dynamodb_table.data.name
}

output "dynamodb_data_table_arn" {
  description = "ARN of the Data DynamoDB table"
  value       = aws_dynamodb_table.data.arn
}

output "s3_config_bucket_name" {
  description = "Name of the S3 bucket used to store config."

  value       = aws_s3_bucket.config_bucket.id
}

output "s3_frontend_bucket_name" {
  description = "Name of the S3 bucket used to store frontend."

  value       = aws_s3_bucket.frontend_bucket.id
}

output "appsync_api_uris" {
  value = aws_appsync_graphql_api.web_monitor_appsync.uris
}

output "frontend_cloudfront" {
  value = aws_cloudfront_distribution.frontend_cf_distribution.domain_name
}