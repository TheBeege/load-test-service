data "aws_availability_zones" "available" {}

resource "aws_vpc" "load_test_service" {
  cidr_block = "${var.vpc_first_two_octets}.0.0/16"

  tags = "${merge(
    map(
     "Name", "${var.vpc_base_name}",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    ),
    "${var.default_tags}")
  }"
}

resource "aws_subnet" "load_test_service" {
  count = "${var.count_azs}"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${var.vpc_first_two_octets}.${count.index}.0/24"
  vpc_id            = "${aws_vpc.load_test_service.id}"

  tags = "${merge(
    map(
     "Name", "${var.vpc_base_name}-node",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    ),
    "${var.default_tags}")
  }"
}

resource "aws_internet_gateway" "load_test_service" {
  vpc_id = "${aws_vpc.load_test_service.id}"

  tags = "${merge(
    map(
      "Name", "${var.vpc_base_name}",
    ),
    "${var.default_tags}")
  }"
}

resource "aws_route_table" "load_test_service" {
  vpc_id = "${aws_vpc.load_test_service.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.load_test_service.id}"
  }
}

resource "aws_route_table_association" "load_test_service" {
  count = "${var.count_azs}"

  subnet_id      = "${aws_subnet.load_test_service.*.id[count.index]}"
  route_table_id = "${aws_route_table.load_test_service.id}"
}
