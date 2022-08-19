# Output value definitions

output "lambda_cron_bucket_name" {
  description = "Name of the S3 bucket used to store function code."

  value = aws_s3_bucket.lambda_cron_bucket.id
}

output "lambda_cron_name" {
  description = "Name of the Lambda function."

  value = aws_lambda_function.cron.function_name
}

output "dynamodb_pub_sub_table_name" {
  description = "Name of the PubSub DynamoDB table"
  value       = aws_dynamodb_table.pub_sub.name
}

output "dynamodb_pub_sub_table_arn" {
  description = "ARN of the PubSub DynamoDB table"
  value       = aws_dynamodb_table.pub_sub.arn
}

output "s3_config_bucket_name" {
  description = "Name of the S3 bucket used to store config."

  value       = aws_s3_bucket.config_bucket.id
}