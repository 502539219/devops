#---------------------------------
# Terraform Variables
#---------------------------------
variable "aws_region" { default = "us-east-1" }
variable "aws_account" { default = "115089117620"}
variable "kms_arn" {default = {}}
variable "bucket_name" {default = {}}
# variable "log_bucket" {default = {}}
variable "policyFile" {default = {}}
variable "acl" {default = "private"}
variable "force_destroy" {default = {}}
variable "tags" {default = {}}
variable "versioning" {default = {}}
variable "bucket_policy" {default = {}}
variable "block_public_acls" {default = {}}
variable "block_public_policy" {default = {}}
variable "ignore_public_acls" {default = {}}
variable "restrict_public_buckets" {default = {}}
variable "s3_folders" {
  type        = list(string)
  description = "The list of S3 folders to create"
  default     = []
}
variable "lifecycle_rule" {default = {}}
variable "object_ownership" {default = "ObjectWriter"}
  


terraform {
 required_version = ">= 0.12.6"
 backend "s3" {}
}

provider "aws" {
  # Note: keep at version 2.47.0, as 2.48.0 looks to have a breaking change with the kubernetes module.
  # version = "2.47.0"
  region  = var.aws_region
}


provider "local" {
  version = "~> 1.2"
}

provider  "random" {
  version = "~> 2.1"
}

#--------------------------------
# Rersources
#--------------------------------

resource "random_pet" "this" {
  length = 2
}

#resource "aws_kms_key" "objects" {
#  description             = "KMS key is used to encrypt bucket objects"
#  deletion_window_in_days = 7
#}

#resource "aws_kms_alias" "objects" {
#  name          = "kms/s3"
#  target_key_id = aws_kms_key.objects.key_id
#}


resource "aws_s3_bucket_object" "object" {
  count = length(var.s3_folders)
  bucket = module.s3_bucket.this_s3_bucket_id
  key    = "${var.s3_folders[count.index]}/"
  source = "/dev/null"
  acl = "private"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_ownership_controls" "objectowner" {
    bucket = module.s3_bucket.this_s3_bucket_id

    rule {
      object_ownership = var.object_ownership
    }
}


resource "aws_s3_bucket" "log_bucket" {
  bucket = "dc-access-log-bucket"
  acl    = "log-delivery-write"
  force_destroy = var.force_destroy

  versioning {
    enabled = true
  }

  lifecycle_rule {
      id      = "log"
      enabled = true
      prefix  = "log/"

      expiration {
        days = 60
        expired_object_delete_marker = true
      }
      noncurrent_version_transition {
        days          = 0
        storage_class = "INTELLIGENT_TIERING"
      }
      noncurrent_version_expiration {
        days = 60
      }
    }

  tags = {
      "rule"      = "log"
      "autoclean" = "true"
      UAI = "UAI3037334"
      ManagementHostType = "None"
      "OptIn/OptOut" = "optout"
      Security = "true"
      Preserve = "true"
      Owner = "aws.bu.ops.admin.115089117620@ge.com"
      "BUC/ADN" = "none"
      Customer = "digitalconnect"
      Project = "digital-connect"
      Region = "us-east-1"
      Confidentiality = "true"
      Compliance = "true"
    }

  logging {
    target_bucket = "dc-access-log-bucket"
    # target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/dc-access-log-bucket/"
  }

#  server_side_encryption_configuration {
#    rule {
#      apply_server_side_encryption_by_default {
#        kms_master_key_id = var.kms_arn
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

#---------------------------------
# EKS Module
#---------------------------------

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "1.12.0"

  create_bucket = true
  bucket = var.bucket_name
  tags = var.tags
  acl = var.acl
  force_destroy = var.force_destroy
  versioning = var.versioning
  attach_policy = true
  policy = file(var.policyFile)
  # s3_folders = var.s3_folders
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = var.kms_arn # kms arn
        sse_algorithm     = "aws:kms"
        # sse_algorithm     = "AES256"
      }
    }
  }
  lifecycle_rule = var.lifecycle_rule

 logging = {
    #target_bucket = "dc-logging-bucket"
    target_bucket = aws_s3_bucket.log_bucket.id
    target_prefix = "log/${var.bucket_name}/"
  }

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

#---------------------------------------
# Output
#----------------------------------------

output "this_s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.this_s3_bucket_id
}

output "this_s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_bucket.this_s3_bucket_arn
}

output "this_s3_bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = module.s3_bucket.this_s3_bucket_bucket_domain_name
}

output "this_s3_bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
}

output "this_s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = module.s3_bucket.this_s3_bucket_hosted_zone_id
}

output "this_s3_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = module.s3_bucket.this_s3_bucket_region
}

output "this_s3_bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = module.s3_bucket.this_s3_bucket_website_endpoint
}

output "this_s3_bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       = module.s3_bucket.this_s3_bucket_website_domain
}