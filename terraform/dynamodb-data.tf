resource "random_pet" "table_name_data" {
  prefix    = "web-monitor-data"
  length   = 4
}

resource "aws_dynamodb_table" "data" {
  name         = random_pet.table_name_data.id

  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "link"

  attribute {
    name = "link"
    type = "S"
  }

  attribute {
    name = "createdAt"
    type = "S"
  }

  attribute {
    name = "category"
    type = "S"
  }

  global_secondary_index {
    hash_key = "category"
    range_key = "createdAt"
    name = "category-index"
    projection_type = "ALL"
  }
}