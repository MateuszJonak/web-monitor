resource "random_pet" "table_name_pub_sub" {
  prefix    = "web-monitor-pub-sub"
  length   = 4
}

resource "aws_dynamodb_table" "pub_sub" {
  name         = random_pet.table_name_pub_sub.id

  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "id"
  range_key = "createdAt"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }
}