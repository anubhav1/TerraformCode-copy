terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  //alias  = "primary"
  profile = "default"  
  region  = "eu-central-1"
}

# ## Specifies the S3 Bucket and DynamoDB table used for the durable backend and state locking
# terraform {
#     backend "s3" {
#       encrypt = true
#       bucket = aws_s3_bucket.my-tf-test-bucket7827.name
#       dynamodb_table = aws_dynamodb_table.terraform-state-lock-dynamo.name
#       key = "path/path/terraform.tfstate"
#       region = "eu-central-1"
#   }
# }

resource "aws_dynamodb_table" "terraform-state-lock-dynamo" {
    name = "Terraform-State-Lock-Dynamo"
    hash_key         = "LockID"
    billing_mode   = "PROVISIONED"
    read_capacity  = 20
    write_capacity = 20
    attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "my-tf-test-bucket7827" {
  bucket = "my-tf-test-bucket7827"
  tags = {
    Name        = "My bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "my-tf-test-bucket7827-block" {
  bucket = aws_s3_bucket.my-tf-test-bucket7827.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}