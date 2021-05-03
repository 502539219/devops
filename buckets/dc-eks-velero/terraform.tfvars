
aws_region = "us-east-1"
aws_account = "115089117620"

# log_bucket = "log-msk"
bucket_name = "dc-eks-velero"

acl = "private"

force_destroy = true

policyFile = "../policy/dc_eks_velero_policy.json"

tags = {
    UAI = "UAI3037334"
    ManagementHostType = "None"
    "OptIn/OptOut" = "optout"
    Security = "true"
    Preserve = "true"
    Owner = "aws.bu.ops.admin.115089117620@ge.com"
    "BUC/ADN" = "none"
    Customer = "digitalconnect"
    Project = "eks-velero"
    Region = "us-east-1"
    Confidentiality = "true"
    Compliance = "true"
}

versioning = {
    enabled = true
}

s3_folders = [
  "backups/ci",
  "backups/monitoring",
  "backups/preprod",
  "backups/prod",
  "restores/ci",
  "restores/monitoring",
  "restores/preprod",
  "restores/prod"
]

kms_arn = "arn:aws:kms:us-east-1:115089117620:key/610e2cdb-626f-49b1-a86d-f194856091f3"

lifecycle_rule = [
    {
      id      = "eks-velero-backup"
      enabled = true
      # prefix  = "dc-devops-tf-session/"
      abort_incomplete_multipart_upload_days = 7

      # tags = {
      #  rule      = "tfstate-rule"
      #  autoclean = "true"
      #}

      expiration = {
        expired_object_delete_marker = true
      }

      noncurrent_version_expiration = {
        days = 8
      }
    },
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true