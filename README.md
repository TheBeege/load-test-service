# Load Test Service (WiP, not running)
This is an out-of-the-box load test service (WiP) designed to run on AWS EKS. The service uses Locust as the load testing tool. It creates a new VPC with all the necessary networking components. The service scales as desired, but scaling must occur before testing. There is no reasonable way to scale mid load test.

Much of this is pulled from [Terraform's guide on EKS](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html).

## Prerequisites
### Tools
* [Terraform](https://www.terraform.io/)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Docker](https://store.docker.com/search?type=edition&offering=community)
### AWS Permissions
* Probably admin. Haven't figured out each individual permission yet

## Setup
1. Create an S3 bucket to maintain your state file if you do not have one already. Make sure this bucket is secure, as secrets are stored in state files in plaintext
2. Create a DynamoDB table for locking state
3. Copy `terraform/vars.tfvars.template` to `terraform/vars.tfvars`, and fill in your desired values
4. Run `terraform output config-map-aws-auth > config-map-aws-auth.yaml`
5. Run `kubectl apply -f config-map-aws-auth.yaml`

## Dev
1.
