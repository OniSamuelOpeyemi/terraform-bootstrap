
provider "aws" {
    region = "us-east-1"  # change to your preferred region
}

# Define the S3 bucket for state storage
resource "aws_s3_bucket" "onie-sammy_terraform_state" {
    bucket          = "onie-sammy-terraform-state-bucket" # Must be globally unique
    
    force_destroy   = true

    # Prevent accidental deletion (Recommended in production env)
   /* lifecycle {
        prevent_destroy = true
    }
   */ 

# Enabling encryption
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }
}
# Enable versioning for state recovery
resource "aws_s3_bucket_versioning" "versioning" {
    bucket = "onie-sammy-terraform-state-bucket"
    versioning_configuration {
        status = "Enabled"
    }
} 

# Define DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
    name              = "sammy-terraform-locks"
    billing_mode      = "PAY_PER_REQUEST"
    hash_key          = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    # Prevent accidental deletion (Recommended in production env)
   /* lifecycle {
        prevent_destroy = true
    }
    */
}