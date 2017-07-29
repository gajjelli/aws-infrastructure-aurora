variable "env" { }
variable "web_port" {}
variable "vpc_cidr" { }
variable "subnet_private1_cidr" { }
variable "subnet_private2_cidr" { }
variable "subnet_public1_cidr" { }
variable "subnet_public2_cidr" { }
variable "allow_all_cidr" { }


# vpc
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags {
    Name = "${var.env}-vpc"
  }
}

# subnets
resource "aws_subnet" "private1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_private1_cidr}"
  availability_zone = "us-west-2b"

  tags {
    Name = "Private-${var.env}_${var.subnet_private1_cidr}"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_private2_cidr}"
  availability_zone = "us-west-2c"

  tags {
    Name = "Private-${var.env}_${var.subnet_private2_cidr}"
  }
}


resource "aws_subnet" "public1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_public1_cidr}"
  availability_zone = "us-west-2b"

  tags {
    Name = "Public-${var.env}_${var.subnet_public1_cidr}"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${var.subnet_public2_cidr}"
  availability_zone = "us-west-2c"

  tags {
    Name = "Public-${var.env}_${var.subnet_public2_cidr}"
  }
}

# elastic ip
resource "aws_eip" "nat" {
  vpc = true
}

# internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "${var.env}-main-igw"
    }
}

# nat gateway
resource "aws_nat_gateway" "natgw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.public1.id}"

   depends_on = [
        "aws_internet_gateway.igw",
        "aws_eip.nat"
    ]
}


# route tables
resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "public-${var.env}-rt"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "${var.allow_all_cidr}"
        nat_gateway_id = "${aws_nat_gateway.natgw.id}"
    }

    tags {
        Name = "private-${var.env}-rt"
    }
}

# route table associations

resource "aws_route_table_association" "public1" {
    subnet_id = "${aws_subnet.public1.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public2" {
    subnet_id = "${aws_subnet.public2.id}"
    route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "private1" {
    subnet_id = "${aws_subnet.private1.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route_table_association" "private2" {
    subnet_id = "${aws_subnet.private2.id}"
    route_table_id = "${aws_route_table.private.id}"
}

resource "aws_security_group" "allow_inbound_from_within_vpc" {
  vpc_id = "${aws_vpc.main.id}"
  name = "allow_inbound_from_within_vpc"
  description = "Allow all inbound traffic originating within the vpc"

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.allow_all_cidr}"]
  }

   tags {
        Name = "allow_inbound_from_within_vpc-sg"
    }
}

resource "aws_security_group" "web_server" {
  vpc_id = "${aws_vpc.main.id}"
  name = "web_server"
  description = "Allow all inbound traffic on http"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["${var.allow_all_cidr}"]
  }

  ingress {
      from_port = "${var.web_port}"
      to_port = "${var.web_port}"
      protocol = "tcp"
      cidr_blocks = ["${var.allow_all_cidr}"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["${var.allow_all_cidr}"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["${var.allow_all_cidr}"]
  }

  tags {
        Name = "web_server-sg"
    }
}


resource "aws_default_security_group" "default-sg" {
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags {
        Name = "default-sg"
    }

}

output "aws_subnet_private1_id" {
  value = "${aws_subnet.private1.id}"
}

output "aws_subnet_private2_id" {
  value = "${aws_subnet.private2.id}"
}

output "aws_subnet_public1_id" {
  value = "${aws_subnet.public1.id}"
}

output "aws_subnet_public2_id" {
  value = "${aws_subnet.public2.id}"
}

output "aws_security_group_allow_inbound_from_within_vpc_id" {
  value = "${aws_security_group.allow_inbound_from_within_vpc.id}"
}


output "aws_security_group_web_server_id" {
  value = "${aws_security_group.web_server.id}"
}

output "aws_default_security_group_id" {
  value = "${aws_default_security_group.default-sg.id}"
}

output "aws_vpc.main.id" {
  value = "${aws_vpc.main.id}"
}

output "aws_vpc.main.name" {
  value = "${aws_vpc.main.name}"
}
