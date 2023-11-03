
# print s3 backend name 

# output "created_s3_bucket_id" {
#   description = "The ID of the created s3 Bucket"
#   value       = module.s3_module
# }


# output "dynamodb_table_name" {
#   value = module.DynamoDB_LockID

#   # ARN here?
#   description = "The ARN of the DynamoDB table"
# }

# print vpv project1 id

output "vpc_name" {
  description = "Project vpc has been created "
  value       = aws_vpc.project1.id
}

