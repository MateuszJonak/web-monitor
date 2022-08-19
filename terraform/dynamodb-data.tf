resource "random_pet" "table_name_data" {
  prefix    = "web-monitor-data"
  length   = 4
}

resource "aws_dynamodb_table" "data" {
  name         = random_pet.table_name_data.id

  # TODO check if provisioning is better
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "id"

  attribute {
    name = "id"
    type = "S"
  }
}