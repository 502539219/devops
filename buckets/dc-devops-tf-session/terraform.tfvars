aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-dc-devops-tf-session"
bucket_name = "dc-devops-tf-session"

acl = "private"

force_destroy = true

policyFile = "../policy/dc_devops_policy.json"

tags = {
    UAI = "UAI3037334"
    ManagementHostType = "None"
    "OptIn/OptOut" = "optout"
    Security = "true"
    Preserve = "true"
    Owner = "aws.bu.ops.admin.115089117620@ge.com"
    "BUC/ADN" = "none"
    Customer = "digitalconnect"
    Project = "eks-s3"
    Region = "us-east-1"
    Confidentiality = "true"
    Compliance = "true"
    CI = "1100707178"
    CIName = "corp-dc-prod-aws-eks"
}

versioning = {
    enabled = true
}

s3_folders = [
    "grafana",
    "eks",
    "msk/cluster",
    "msk/config",
    "efs",
    "eks",
    "iam",
    "rds",
    "s3",
    "sqs"
]

kms_arn = "arn:aws:kms:us-east-1:115089117620:key/610e2cdb-626f-49b1-a86d-f194856091f3"

lifecycle_rule = [
    {
      id      = "dc-devops"
      enabled = true
      # prefix  = "dc-devops-tf-session/"
      abort_incomplete_multipart_upload_days = 7

      expiration = {
			"expired_object_delete_marker" = true
		  }

      noncurrent_version_transition = [
	      {
        days          = 30
        storage_class = "STANDARD_IA"
      	},
        {
        days          = 60
        storage_class = "GLACIER"
      	},
     ]

      noncurrent_version_expiration = {
        days = 365
      }
    },
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true