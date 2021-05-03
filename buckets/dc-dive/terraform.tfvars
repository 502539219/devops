aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-dc-devops-tf-session"
bucket_name = "dc-dive"

acl = "private"

object_ownership = "BucketOwnerPreferred"

force_destroy = true

policyFile = "../policy/dc_dive_policy.json"

tags = {
    UAI = "UAI3026613"
    ManagementHostType = "None"
    "OptIn/OptOut" = "optout"
    Security = "true"
    Preserve = "true"
    Owner = "aws.bu.ops.admin.115089117620@ge.com"
    "BUC/ADN" = "none"
    Customer = "dive"
    Project = "dive"
    Region = "us-east-1"
    Confidentiality = "true"
    Compliance = "true"
}

versioning = {
    enabled = true
}

s3_folders = [
	"engdev",
	"engqa",
	"dev/62592105c68cbe53",
	"dev/32637d26909253c4",
	"dev/c9be7bec3edf108b",
	"stg/62592105c68cbe53",
	"stg/c9be7bec3edf108b",
	"stg/32637d26909253c4",
	"prod/62592105c68cbe53",
	"prod/c9be7bec3edf108b",
	"prod/32637d26909253c4",
	"dev/d31339e54a7dd4b1",
	"stg/d31339e54a7dd4b1",
	"prod/d31339e54a7dd4b1",
	"dev/dive-es-snapshot-s3-repo",
	"dev/d49d384481cecda5",
	"stg/d49d384481cecda5",
	"prod/d49d384481cecda5",
	"dev/d49d384481cecda5/new/144/296",
	"dev/d49d384481cecda5/new/144/297",
	"dev/d49d384481cecda5/new/144/298",
	"dev/d49d384481cecda5/new/144/299"
]

kms_arn = "arn:aws:kms:us-east-1:115089117620:key/610e2cdb-626f-49b1-a86d-f194856091f3"

lifecycle_rule = [
	{
		id      = "dc-dive engdev"
		enabled = true
		prefix  = "dc-dive/engdev/dive-es-snapshot-s3-repo/*"
		abort_incomplete_multipart_upload_days = 7
		
		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			days = 7,
			"expired_object_delete_marker" = true
		}

		noncurrent_version_expiration = {
        	days = 7
      	}
    },
	{
		id      = "dc-dive engqa"
		enabled = true
		prefix  = "dc-dive/engqa/dive-es-snapshot-s3-repo/*"
		abort_incomplete_multipart_upload_days = 7
		
		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			days = 7,
			"expired_object_delete_marker" = true
		}

		noncurrent_version_expiration = {
        	days = 7
      	}
    },
    {
		id      = "dc-dive dev"
		enabled = true
		prefix  = "dc-dive/dev/dive-es-snapshot-s3-repo/*"
		abort_incomplete_multipart_upload_days = 7
		
		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			days = 7
		}

		noncurrent_version_expiration = {
        	days = 7
      	}
    },
	{
		id      = "dc-dive stage"
		enabled = true
		prefix  = "dc-dive/stg/dive-es-snapshot-s3-repo/*"
		abort_incomplete_multipart_upload_days = 7
		
		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			days = 7,
			"expired_object_delete_marker" = true
		}

		noncurrent_version_expiration = {
        	days = 7
      	}
    },
	{
		id      = "dc-dive prod"
		enabled = true
		prefix  = "dc-dive/prod/dive-es-snapshot-s3-repo/*"
		abort_incomplete_multipart_upload_days = 7
		
		transition = [
			{
			days          = 0
			storage_class = "INTELLIGENT_TIERING"
			},
		]

		expiration = {
			days = 7,
			"expired_object_delete_marker" = true
		}

		noncurrent_version_expiration = {
        	days = 7
      	}
    },
	{
		id      = "dc-dive dev for power"
		enabled = true
		prefix  = "dc-dive/dev/d49d384481cecda5/*"
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
        	days = 180
      	}
    },
	{
		id      = "dc-dive stage for power"
		enabled = true
		prefix  = "dc-dive/stg/d49d384481cecda5/*"
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
        	days = 180
      	}
    },
	{
		id      = "dc-dive prod for power"
		enabled = true
		prefix  = "dc-dive/prod/d49d384481cecda5/*"
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
        	days = 180
      	}
    },
	{
		id      = "dc-dive prod corp"
		enabled = true
		prefix  = "dc-dive/prod/d31339e54a7dd4b1/*"
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
        	days = 180
      	}
    }

  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true