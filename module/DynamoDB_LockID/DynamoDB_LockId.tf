# ------------------------------------------------------------------------------
# CREATE THE DYNAMODB TABLE FOR LOCKID
# ------------------------------------------------------------------------------

resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}