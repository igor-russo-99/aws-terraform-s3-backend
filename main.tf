terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

 #  backend "s3" {

 #   bucket         = "igorsr-dev-terraform-state-bucket" 
 #   key            = "state/terraform.tfstate"
 #   region         = "us-east-1"
 #   encrypt        = true
 #   kms_key_id     = "alias/terraform-bucket-key"
 #   dynamodb_table = "terraform-state" 
 # }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

##### S3 bucket to store Terraform state #####

resource "aws_kms_key" "terraform-bucket-key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "bucket-key-alias" {
  name          = "alias/terraform-bucket-key"
  target_key_id = aws_kms_key.terraform-bucket-key.key_id
}


resource "aws_s3_bucket" "terraform-state" {
  bucket = var.terraform-state-bucket-name
}

resource "aws_s3_bucket_versioning" "s3-versioning-terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-encryption-terraform-state" {
  bucket = aws_s3_bucket.terraform-state.id


  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.terraform-state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform-state" {
  name = "terraform-state"
  read_capacity = 20
  write_capacity = 20
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
