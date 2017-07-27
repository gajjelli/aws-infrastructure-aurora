variable "env" { }
variable "master_db_name" {}
variable "master_username" {}
variable "master_password" {}
variable "aws_subnet_public1_id" {}
variable "aws_subnet_public2_id" {}
variable "vpc_main_name" {}
variable "vpc_main_id" {}
variable "vpc_security_group_ids" {}

variable "subnet_public_count" {}
variable "subnet_private_count" {}

########################
## Cluster
########################

resource "aws_rds_cluster" "aurora_cluster" {
cluster_identifier            = "${var.env}-aurora-cluster"
database_name                 = "mydb"
master_username               = "${var.master_db_name}"
master_password               = "${var.master_username}"
backup_retention_period       = 14
preferred_backup_window       = "01:00-02:00"
preferred_maintenance_window  = "sun:02:00-sun:04:00"
db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
final_snapshot_identifier     = "${var.env}-aurora-cluster"
vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

tags {
Name         = "${var.env}-Aurora-DB-Cluster"
VPC          = "${var.vpc_main_id}"
ManagedBy    = "terraform"
Environment  = "${var.env}"
    }
lifecycle {
create_before_destroy = true
    }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
name          = "${var.env}_aurora_db_subnet_group"
description   = "Allowed subnets for Aurora DB cluster instances"
subnet_ids    = ["${var.aws_subnet_public1_id}","${var.aws_subnet_public1_id}"]
tags {
Name         = "${var.env}-Aurora-DB-Subnet-Group"
VPC          = "${var.vpc_main_name}"
ManagedBy    = "terraform"
Environment  = "${var.env}"
    }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
count                 = "${var.subnet_public_count}"
identifier            = "${var.env}-aurora-instance-${count.index}"
cluster_identifier    = "${aws_rds_cluster.aurora_cluster.id}"
instance_class        = "db.t2.small"
db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
publicly_accessible   = true
tags {
Name         = "${var.env}-Aurora-DB-Instance-${count.index}"
VPC          = "${var.vpc_main_name}"
ManagedBy    = "terraform"
Environment  = "${var.env}"
    }
lifecycle {
create_before_destroy = true
    }
}

output "cluster_address" {
value = "${aws_rds_cluster.aurora_cluster.address}"
}
