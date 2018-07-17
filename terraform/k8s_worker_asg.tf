data "aws_ami" "eks-worker" {
  filter = {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["${var.aws_account_id}"] # Amazon Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml
locals {
  load_test_service-node-userdata = <<USERDATA
#!/bin/bash -xe

CA_CERTIFICATE_DIRECTORY=/etc/kubernetes/pki
CA_CERTIFICATE_FILE_PATH=$CA_CERTIFICATE_DIRECTORY/ca.crt
mkdir -p $CA_CERTIFICATE_DIRECTORY
echo "${aws_eks_cluster.demo.certificate_authority.0.data}" | base64 -d >  $CA_CERTIFICATE_FILE_PATH
INTERNAL_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.load_test_service.endpoint},g /var/lib/kubelet/kubeconfig
sed -i s,CLUSTER_NAME,${var.cluster_name},g /var/lib/kubelet/kubeconfig
sed -i s,REGION,${var.region},g /etc/systemd/system/kubelet.service
sed -i s,MAX_PODS,20,g /etc/systemd/system/kubelet.service
sed -i s,MASTER_ENDPOINT,${aws_eks_cluster.load_test_service.endpoint},g /etc/systemd/system/kubelet.service
sed -i s,INTERNAL_IP,$INTERNAL_IP,g /etc/systemd/system/kubelet.service
DNS_CLUSTER_IP=10.100.0.10
if [[ $INTERNAL_IP == 10.* ]] ; then DNS_CLUSTER_IP=172.20.0.10; fi
sed -i s,DNS_CLUSTER_IP,$DNS_CLUSTER_IP,g /etc/systemd/system/kubelet.service
sed -i s,CERTIFICATE_AUTHORITY_FILE,$CA_CERTIFICATE_FILE_PATH,g /var/lib/kubelet/kubeconfig
sed -i s,CLIENT_CA_FILE,$CA_CERTIFICATE_FILE_PATH,g  /etc/systemd/system/kubelet.service
systemctl daemon-reload
systemctl restart kubelet
USERDATA
}

resource "aws_launch_configuration" "load_test_service" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.load_test_service-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "m4.large"
  name_prefix                 = "${var.vpc_base_name}"
  security_groups             = ["${aws_security_group.load_test_service-node.id}"]
  user_data_base64            = "${base64encode(local.load_test_service-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "default_tags_for_asg" {
  count = "${length(var.default_tags)}"
  template = {
    key = "$${tag_key}"
    value = "$${tag_value}"
    propagate_at_launch = true
  }
  vars = {
    tag_key = "${keys(var.default_tags)[count.index]}"
    tag_value = "${values(var.default_tags)[count.index]}"
  }
}

resource "aws_autoscaling_group" "load_test_service" {
  desired_capacity     = 2
  launch_configuration = "${aws_launch_configuration.load_test_service.id}"
  max_size             = 2
  min_size             = 1
  name                 = "${var.vpc_base_name}"
  vpc_zone_identifier  = ["${aws_subnet.load_test_service.*.id}"]

  tag {
    key                 = "Name"
    value               = "${var.vpc_base_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tags = "${data.template_file.default_tags_for_asg.rendered}"
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.load_test_service-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}
