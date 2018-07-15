resource "aws_security_group" "load_test_service-node" {
  name        = "${var.cluster_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.load_test_service.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    map(
     "Name", "${var.vpc_base_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "owned",
    ),
    "${var.default_tags}"
  }"
}

resource "aws_security_group_rule" "load_test_service-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.load_test_service-node.id}"
  source_security_group_id = "${aws_security_group.load_test_service-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "load_test_service-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.load_test_service-node.id}"
  source_security_group_id = "${aws_security_group.load_test_service-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "load_test_service-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.load_test_service-cluster.id}"
  source_security_group_id = "${aws_security_group.load_test_service-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
