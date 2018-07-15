resource "aws_security_group" "load_test_service-cluster" {
  name        = "${var.cluster_name}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.load_test_service.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
      map(
        "Name", "${var.vpc_base_name}",
      ),
      "${var.default_tags}"
    )
  }"
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "load_test_service-ingress-https" {
  cidr_blocks       = "${var.external_access_cidrs}"
  description       = "Allow external access to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.load_test_service-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
