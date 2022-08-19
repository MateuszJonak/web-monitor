resource "random_pet" "config_bucket_name" {
  prefix = "web-monitor-config"
  length = 4
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = random_pet.config_bucket_name.id

  force_destroy = true
}

resource "aws_s3_bucket_acl" "config_bucket_acl" {
  bucket = aws_s3_bucket.config_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "config_json" {
  bucket = aws_s3_bucket.config_bucket.id

  key    = var.config_file_name
  source = "${path.module}/${var.config_file_name}"

  etag   = filemd5("${path.module}/${var.config_file_name}")
}