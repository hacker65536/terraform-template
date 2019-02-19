


base
--
- vpc
- subunet (public , private)
- subnet (public(natgw) , private(nat)) (option)
- route table /associate
- security group
- internet gateway
- dhcp option set
- key pair
- nat gateway (option)
- vpc endpoint (option)


### subnet

data resourceでフィルターして利用できるようにsubnet毎の役割をタグ `tag:SubnetRole`をつける
```HCL
resource "aws_subnet" "pri" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pri","SubnetRole","pri"))}"
}
```
```HCL
data "aws_subnet_ids" "pri" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    SubnetRole = "pri"
  }
}
```
```HCL
resource "aws_db_subnet_group" "subnet" {
  name       = "${terraform.workspace}-db-subnet"
  subnet_ids = ["${data.aws_subnet_ids.pri.ids}"]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-db-subnet"))}"
}
```

rds
--
- db_instance
- db_paramter_group
- db_option_group
- rds_cluster
- rds_cluster_instance
- rds_cluster_parameter_group

### db_instance

```HCL
locals {
  mysql80engines = [
    "8.0.11",
    "8.0.13",
  ]
}

resource "aws_db_instance" "mysql80" {
  count      = "${length(local.mysql80engines)}"
  identifier = "${terraform.workspace}-mysql${replace(element(local.mysql80engines,count.index),".","")}"

  allocated_storage = "${local.storage}"
  storage_type      = "gp2"

  engine               = "mysql"
  engine_version       = "${element(local.mysql80engines,count.index)}"
  instance_class       = "${local.db_class}"
  name                 = "${local.db_name}"
  username             = "${local.rds_sec["username"]}"
  password             = "${local.rds_sec["password"]}"
  parameter_group_name = "${aws_db_parameter_group.mysql80.id}"

  db_subnet_group_name   = "${aws_db_subnet_group.subnet.id}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  skip_final_snapshot    = true
  apply_immediately      = true

  monitoring_interval     = "${local.rds_enhanced_monitoring_interval}"
  monitoring_role_arn     = "${aws_iam_role.rds_enhanced_monitoring_role.arn}"
  backup_retention_period = 1
  backup_window           = "${local.backup_window}"
   
  /*
  snapshot_identifier = "${terraform.workspace}-mysql${replace(
  element(local.mysql80engines,count.index),".",""
  )}-2002000000"
  */
  
  multi_az = false
  enabled_cloudwatch_logs_exports = [
    "${local.cloudwatch_logs_exports}",
  ]
  tags = "${merge(
    local.tags, 
    map("Name", "${terraform.workspace}-mysql${replace(element(local.mysql80engines,count.index),".","")}"))
    }"
}
```
### paramater

- 大量にqueryを実行するために`max_prepqred_stmt_count`をmaxに設定。
- slow logをcloudwatchに出力するための設定
```HCL
resource "aws_db_parameter_group" "mysql80" {
  name   = "${terraform.workspace}-mysql80-parameter-group"
  family = "mysql8.0"
  tags   = "${local.tags}"

  parameter {
    name  = "max_prepared_stmt_count"
    value = "1048576"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "0.5"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }
  
}
```
