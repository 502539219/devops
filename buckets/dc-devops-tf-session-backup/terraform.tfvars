aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-dc-devops-tf-session"
bucket_name = "dc-devops-tf-session-backup"

acl = "private"

force_destroy = true

policyFile = "../policy/dc_devops_backup_policy.json"

tags = {
    UAI = "UAI3037334"
    ManagementHostType = "None"
    "OptIn/OptOut" = "optout"
    Security = "true"
    Preserve = "true"
    Owner = "aws.bu.ops.admin.115089117620@ge.com"
    "BUC/ADN" = "none"
    Customer = "digitalconnect"
    Project = "eks-s3-tf-backup"
    Region = "us-east-1"
    Confidentiality = "true"
    Compliance = "true"
}

versioning = {
    enabled = false
}

s3_folders = []

kms_arn = "arn:aws:kms:us-east-1:115089117620:key/610e2cdb-626f-49b1-a86d-f194856091f3"

lifecycle_rule = [
    {
		id      = "dc-devops-backup"
		enabled = true
		# prefix  = "dc-devops-tf-session-backup/"
		abort_incomplete_multipart_upload_days = 7

		# tags = {
		#  rule      = "tfstate-rule"
		#  autoclean = "true"
		#}

		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			"expired_object_delete_marker" = true
		}
    },
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true