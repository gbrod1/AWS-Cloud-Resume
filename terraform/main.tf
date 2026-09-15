terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "resume_website" {
  bucket = "gloria-brodrick-resume-2026"
}

resource "aws_s3_bucket_ownership_controls" "resume_website" {
  bucket = aws_s3_bucket.resume_website.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
