variable "state_bucket" {
  description = "The S3 bucket where the Terraform state will be stored"
}

variable "state_key" {
  description = "The key path in the S3 bucket where the Terraform state will be stored"
}

variable "state_region" {
  description = "The region where your state S3 bucket is located"
}

variable "state_lock_table" {
  description = "The DynamoDB table to be used for locking Terraform state"
}

variable "state_profile" {
  description = "The AWS profile used to manage the state in S3 and DynamoDB. Defaults to 'default'"
  default = "default"
}

variable "profile" {
  description = "The AWS profile used to standup infrastructure. Defaults to 'default'"
  default = "default"
}

variable "region" {
  description = "The region where your infrastructure will live. Defaults to 'us-east-1'"
  default = "us-east-1"
}
