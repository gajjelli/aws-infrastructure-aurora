########################
## Cluster
########################

resource "aws_rds_cluster" "aurora_cluster" {
cluster_identifier            = "${var.env}_aurora_cluster"
database_name                 = "mydb"
master_username               = "${var.master_db_name}"
master_password               = "${var.master_username}"
backup_retention_period       = 14
preferred_backup_window       = "01:00-02:00"
preferred_maintenance_window  = "sun:02:00-sun:04:00"
db_subnet_group_name          = "${aws_db_subnet_group.aurora_subnet_group.name}"
final_snapshot_identifier     = "${var.env}_aurora_cluster"
vpc_security_group_ids        = [
"${var.vpc_rds_security_group_id}"
    ]
tags {
Name         = "${var.env}-Aurora-DB-Cluster"
VPC          = "${var.vpc_name}"
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
subnet_ids    = [
"${aws_subnet.public.id},${aws_subnet.public1.id}"
    ]
tags {
Name         = "${var.env}-Aurora-DB-Subnet-Group"
VPC          = "${var.vpc_name}"
ManagedBy    = "terraform"
Environment  = "${var.environment_name}"
    }
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
count                 = "${length(split(",", var.vpc_rds_subnet_ids))}"
identifier            = "${var.env}_aurora_instance_${count.index}"
cluster_identifier    = "${aws_rds_cluster.aurora_cluster.id}"
instance_class        = "db.t2.small"
db_subnet_group_name  = "${aws_db_subnet_group.aurora_subnet_group.name}"
publicly_accessible   = true
tags {
Name         = "${var.env}-Aurora-DB-Instance-${count.index}"
VPC          = "${var.vpc_name}"
ManagedBy    = "terraform"
Environment  = "${var.env}"
    }
lifecycle {
create_before_destroy = true
    }
}

########################
## Output
########################
output "cluster_address" {
value = "${aws_rds_cluster.aurora_cluster.address}"
}
