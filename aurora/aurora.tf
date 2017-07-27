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

variable "storage_encrypted" { default = true }
variable "apply_immediately" { default = false }

########################
## Cluster
########################

resource "aws_rds_cluster" "aurora_cluster" {
cluster_identifier            = "${var.env}-aurora-cluster"
database_name                 = "${var.master_db_name}"
master_username               = "${var.master_username}"
master_password               = "${var.master_password}"
backup_retention_period       = 14
preferred_backup_window       = "01:00-02:00"
preferred_maintenance_window  = "sun:02:00-sun:04:00"
db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_parameter_group.id}"
final_snapshot_identifier     = "${var.env}-aurora-cluster"
vpc_security_group_ids        = ["${var.vpc_security_group_ids}"]
storage_encrypted             = "${var.storage_encrypted}"
kms_key_id                    = "${aws_kms_key.aurora.arn}"
apply_immediately             = "${var.apply_immediately}"

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
subnet_ids    = ["${var.aws_subnet_public1_id}","${var.aws_subnet_public2_id}"]
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
db_parameter_group_name = "${aws_db_parameter_group.aurora_parameter_group.id}"
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

resource "aws_db_parameter_group" "aurora_parameter_group" {
  name        = "tf-rds1-${var.env}"
  family      = "aurora5.6"
  description = "Terraform-managed parameter group for tf-rds1-${var.env}"

  tags {
    Name = "tf-rds1-${var.env}"
  }
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_parameter_group" {
  name        = "tf-rds1-${var.env}"
  family      = "aurora5.6"
  description = "Terraform-managed cluster parameter group for tf-rds1-${var.env}"

  tags {
    Name = "tf-rds1-${var.env}"
  }
}

output "cluster_address" {
value = "${aws_rds_cluster.aurora_cluster.address}"
}


resource "aws_kms_key" "aurora" {
  description = "RDS master key for ${var.env}-aurora}"
  deletion_window_in_days = 30
  enable_key_rotation = "true"
}

resource "aws_kms_alias" "aurora" {
  name = "alias/${var.env}-rds-key"
  target_key_id = "${aws_kms_key.aurora.key_id}"
}
