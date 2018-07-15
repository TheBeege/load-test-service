variable "state_bucket" {
  type = "string"
  description = "The S3 bucket where the Terraform state will be stored"
}

variable "state_key" {
  type = "string"
  description = "The key path in the S3 bucket where the Terraform state will be stored"
}

variable "state_region" {
  type = "string"
  description = "The region where your state S3 bucket is located"
}

variable "state_lock_table" {
  type = "string"
  description = "The DynamoDB table to be used for locking Terraform state"
}

variable "state_profile" {
  type = "string"
  description = "The AWS profile used to manage the state in S3 and DynamoDB. Defaults to 'default'"
  default = "default"
}

variable "profile" {
  type = "string"
  description = "The AWS profile used to standup infrastructure. Defaults to 'default'"
  default = "default"
}

variable "region" {
  type = "string"
  description = "The region where your infrastructure will live. Defaults to 'us-east-1'"
  default = "us-east-1"
}

variable "default_tags" {
  type = "map"
  description = "Tags you would like applied to all infrastructure by default"
}

variable "count_azs" {
  type = "string"
  description = "Number of availability zones to create in the VPC. Defaults to 3"
  default = "3"
}

variable "vpc_first_two_octets" {
  type = "string"
  description = "The first two octets of the VPC CIDR block. The VPC will be created with the /16 space. Subnets will be created within this space. Should be written as '10.0'"
}

variable "vpc_base_name" {
  type = "string"
  description = "The base value for the Name tag in VPC objects and other objects. Defaults to 'load-test-servce'"
  default = "load-test-service"
}

variable "external_access_cidrs" {
  type = "list"
  description = "A list of CIDR blocks to allow external access to the Kubernetes cluster"
}

variable "cluster_name" {
  type = "string"
  description = "The name for your Kubernetes cluster. Defaults to 'load-test-service'"
  default = "load-test-service"
}

variable "aws_account_id" {
  type = "string"
  description = "The numeric AWS account ID"
}
