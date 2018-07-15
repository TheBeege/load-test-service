resource "aws_eks_cluster" "load_test_service" {
  name            = "${var.cluster_name}"
  role_arn        = "${aws_iam_role.load_test_service.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.load_test_service-cluster.id}"]
    subnet_ids         = ["${aws_subnet.load_test_service.*.id}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachmentload_test_service-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.load_test_service-AmazonEKSServicePolicy",
  ]
}
