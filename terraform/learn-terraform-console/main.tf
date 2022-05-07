terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }

  required_version = ">= 1.0.5"
}

locals {
  local_ip = chomp(data.http.local_ip.body)
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "data" {
  bucket_prefix = var.bucket_prefix

  force_destroy = true
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.data.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "private" {
  bucket = aws_s3_bucket.data.id

  policy = jsonencode({
    "Id" = "S3DataBucketPolicy"
    "Statement" = [
      {
        "Action" = "s3:*"
        "Condition" = {
          "NotIpAddress" = {
            "aws:SourceIp" = local.local_ip
          }
        }
        "Effect"    = "Deny"
        "Principal" = "*"
        "Resource" = [
          aws_s3_bucket.data.arn,
          "${aws_s3_bucket.data.arn}/*",
        ]
        "Sid" = "IPAllow"
      },
    ]
    "Version" = "2012-10-17"
  })
}

data "aws_s3_objects" "data_bucket" {
  bucket = aws_s3_bucket.data.bucket
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}
