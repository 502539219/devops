aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-dc-devops-tf-session"
bucket_name = "digital-corp-migration"

acl = "private"

force_destroy = true

policyFile = "../policy/digital_corp_migration_policy.json"

tags = {
  Environment = "global"
  Name = "digital-corp-migration"
  "Support Group" = "DCInfraOps@ge.com"
  CIName = "sap-po-em"
  CI = "UAI3002336"
  UAI = "UAI3002336"
  Product = "SAPPO"
}

versioning = {
    enabled = true
}

s3_folders = [
    "dev/app",
	"qa/app",
	"prd/app",
	"dev/db",
	"qa/db",
	"prd/db"
]

kms_arn = "arn:aws:kms:us-east-1:115089117620:key/610e2cdb-626f-49b1-a86d-f194856091f3"

lifecycle_rule = [
    {
      id      = "digital-corp-migration"
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
        days = 120
      }
    },
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true