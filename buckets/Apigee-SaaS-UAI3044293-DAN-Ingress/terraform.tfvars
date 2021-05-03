aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-dc-devops-tf-session"
bucket_name = "apigee-saas-uai3044293-dan-ingress"

acl = "private"

force_destroy = true

policyFile = "../policy/Apigee-SaaS-UAI3044293-DAN-Ingress_policy.json"

tags = {
    UAI = "UAI3044293"
    ManagementHostType = "None"
    "OptIn/OptOut" = "optout"
    Security = "true"
    Preserve = "true"
    Owner = "aws.bu.ops.admin.115089117620@ge.com"
    "BUC/ADN" = "none"
    Customer = "digitalconnect"
    Project = "apigee"
    Region = "us-east-1"
    Confidentiality = "true"
    Compliance = "true"
}

versioning = {
    enabled = false
}

s3_folders = ["apigee_saas_logs"]

kms_arn = ""

lifecycle_rule = [
    {
		id      = "apigee-saas-uai3044293-dan-ingress"
		enabled = true
		prefix  = "apigee-saas-uai3044293-dan-ingress/apigee_saas_logs/*"
		abort_incomplete_multipart_upload_days = 7

		# tags = {
		#  rule      = "tfstate-rule"
		#  autoclean = "true"
		#}

		# transition = [
		# 	{
		# 	days          = 0
		# 	storage_class = "INTELLIGENT_TIERING"
		# 	},
		# ]

		expiration = {
			days = 1
			"expired_object_delete_marker" = true
		}
    },
  ]

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false