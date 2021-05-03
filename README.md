# S3 Architecture 

![ScreenShot](https://github.build.ge.com/digital-connect-devops/aws-s3-tf/blob/master/image/s3_architecture.PNG)


# AWS S3 bucket and objects Terraform module

This repo is for creating s3 bucket and objects with their specific required configurations.Terraform module which creates S3 bucket on AWS with all (or almost all) features provided by Terraform AWS provider. 

These features of S3 bucket are configured here: 

1. s3 bucket  
2. s3 bucket objects 
3. access logging 
4. versioning 
5. lifecycle rules 
6. server-side encryption 
7. tags 
8. force_destroy 

There are other supported features which can be configured as required. Please find the link for other possible inputs and configurations. 
`https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/1.12.0` 

---

# Process of creating bucket

1. Every bucket will have seperate subfolder inside ***"buckets"***. And create two files ***"backend_config.tfvars"*** and ***"terraform.tfvars"*** 
	1. ***"backend_config.tfvars"*** : This file will have the s3 backend path where the tfstate file will be saved i.e bucket ***"dc-devops-tf-session"*** with there tfstate name. 
	2. ***"terraform.tfvars"***: This file will have all required configuration values for that specific bucket.

2. Once configuration is done, run jenkins job ***dc-aws-s3-tf*** with bucket subfolder name (as mentioned in git repo path ***"aws-s3-tf/buckets/<subfolder name>"***)

---
# Process of migrating any object from one s3 bucket location to another location

In order to migrate any files/object from source bucket to target bucket, run the jenkins job ***"dc-aws-s3-migrate"*** with parameters: 
1. Source path of that file/object 
2. Destination bucket path 
3. specific file name as required example (xxx* or *yyy* or *zzz or *)






