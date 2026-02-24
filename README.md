# Bootstrapping Terraform Remote Backend
---
Have you ever heard of the phrase "chicken-and-egg" in terraform. You need Terraform to provision the backend resources, but Terraform itself relies on the backend for state management (bootstrapping a Terraform remote backend). 
The standard approach is to start with the local backend, this enables us to provision the remote backend resources with the local state and import them into our configuration so that even the remote backend resources can be managed by terraform as well

 ## Prerequisites
- Terraform installed (v1.0+ recommended).
- AWS CLI configured with credentials (or equivalent for your provider).
- Basic Terraform knowledge.

## Step-by-Step Guide
1. Prepare Your Terraform Configuration:
- Create a [main.tf](./main.tf) file (or similar) that defines both your backend resources and any other infrastructure you want to manage.
- Initially, do not include a backend block in your config—this defaults Terraform to using local state (stored in terraform.tfstate).

2. Initialize and Apply with Local State:
- Run _terraform init_ to initialize the working directory (uses local backend by default).
- Run _terraform plan_ to preview changes.
- Run _terraform apply_ to provision the backend resources (S3 bucket and DynamoDB table) and any other infra. This creates a local terraform.tfstate file.
- At this point, your backend resources exist in AWS, but Terraform is still using local state.

3. Update Config to Use Remote Backend:
- Now add a backend block to your main.tf (or better, in a separate [backend.tf](backend.tf) for clarity). Point it to the newly created resources.

```bash

terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"  # Match the bucket name from step 1
    key            = "global/state/terraform.tfstate"  # Path within the bucket for this project's state
    region         = "us-west-2"  # Match your provider region
    dynamodb_table = "my-terraform-locks"  # Match the DynamoDB table name
    encrypt        = true  # Optional: Enable server-side encryption
  }
}

```
_Important: Do not change any other parts of the config yet. The resource definitions stay the same._

4. Re-Initialize and Migrate State:
- Run terraform init again. Terraform will detect the new backend config and prompt you to migrate the local state to the remote backend.
Answer _"yes"_ to copy the state.

This migrates terraform.tfstate to S3, and future operations will use the remote backend.
Run terraform plan to verify—no changes should be proposed if everything matches.
If you have other infra (like the EC2 example), it's now managed via remote state.

4. Clean Up Local State (Optional):
- Once migrated, you can safely delete the local **terraform.tfstate** and **terraform.tfstate.backup** files.
Commit your code to version control, but add .terraform/ and *.tfstate* to .gitignore to avoid checking in local state.

_If you need to add more infra, just update main.tf and apply as usual._