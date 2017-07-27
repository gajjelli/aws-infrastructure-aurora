provider "aws" {
  region = "us-west-2"
}

variable "env" { }
variable "ami_id" {}
variable "account_num" { }
variable "web_port" {}
variable "vpc_cidr" { }
variable "subnet_private1_cidr" { }
variable "subnet_private2_cidr" { }
variable "subnet_public1_cidr" { }
variable "subnet_public2_cidr" { }
variable "allow_all_cidr" { }
variable "master_db_name" { }
variable "master_username" { }
variable "master_password" { }
variable "key_rsa_pub" { }

variable "subnet_public_count" { }
variable "subnet_private_count" { }

module "vpc" {
  source = "./vpc"
  env = "${var.env}"
  web_port = "${var.web_port}"
  vpc_cidr = "${var.vpc_cidr}"
  subnet_private1_cidr = "${var.subnet_private1_cidr}"
  subnet_private2_cidr = "${var.subnet_private2_cidr}"
  subnet_public1_cidr = "${var.subnet_public1_cidr}"
  subnet_public2_cidr = "${var.subnet_public2_cidr}"
  allow_all_cidr = "${var.allow_all_cidr}"
}

module "aurora" {
  source = "./aurora"

  env = "${var.env}"
  master_db_name = "${var.master_db_name}"
  master_username = "${var.master_username}"
  master_password = "${var.master_password}"
  aws_subnet_public1_id = "${module.vpc.aws_subnet_public1_id}"
  aws_subnet_public2_id = "${module.vpc.aws_subnet_public2_id}"
  vpc_main_name = "${module.vpc.aws_vpc.main.name}"
  vpc_security_group_ids = "${module.vpc.aws_default_security_group_id}"
  vpc_main_id = "${module.vpc.aws_vpc.main.id}"

  subnet_public_count="${var.subnet_public_count}"
  subnet_private_count="${var.subnet_private_count}"

}

output "vpc_id" {
  value = "${module.vpc.aws_vpc.main.id}"
}

output "vpc_name" {
  value = "${module.vpc.aws_vpc.main.name}"
}

output "cluster_address" {
value = "${module.aurora.cluster_address}"
}
