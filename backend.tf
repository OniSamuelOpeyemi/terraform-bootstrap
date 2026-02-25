 terraform {
  backend "s3" {
    bucket         = "onie-sammy-terraform-state-bucket"  # Match the bucket name from step 1
    key            = "global/state/terraform.tfstate"  # Path within the bucket for this project's state
    region         = "us-east-1"  # Match your provider region
    dynamodb_table = "sammy-terraform-locks"  # Match the DynamoDB table name
    encrypt        = true  # Optional: Enable server-side encryption
  }
}
