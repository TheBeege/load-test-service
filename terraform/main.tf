terraform {
  backend "s3" = {
    bucket = "${vars.state_bucket}"
    key    = "${vars.state_key}"
    region = "${vars.state_region}"
    dynamodb_table = "${vars.state_lock_table}"
    profile = "${vars.state_profile}"
  }
}

provider "aws" {
  profile = "${vars.profile}"
  region = "${vars.region}"
}
