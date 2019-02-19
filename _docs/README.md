terraform director
--
- base (vpc,network,etc)
- rds (db instance ,etc)
- ec2 (preparation for data set)
- worker_ec2 (client: spot_fleet, sms)


base
--
- vpc
- subnet (public , private)
- subnet (public(natgw) , private(nat)) (option)
- route table /associate
- security group
- internet gateway
- dhcp option set
- key pair
- nat gateway (option)
- vpc endpoint (option)

### nat gateway
nat 環境は選択可 routing,subnetも`count="${var.nat == 0 ? 0 : 1}"`で制御
```HCL
resource "aws_nat_gateway" "nat" {
  count         = "${var.nat == 0 ? 0 : 1}"
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.pub_nat.*.id[0]}"
}

resource "aws_eip" "nat" {
  count = "${var.nat == 0 ? 0 : 1}"
  vpc   = true
  tags  = "${merge(local.tags, map("Name", "${terraform.workspace}-nat-ip"))}"
}
```
```HCL
resource "aws_route" "pri_nat" {
  count                  = "${var.nat == 0 ? 0 : 1}"
  route_table_id         = "${aws_route_table.pri_nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
  depends_on             = ["aws_route_table.pri_nat"]
}

resource "aws_route_table_association" "pri_nat" {
  count          = "${var.nat == 0 ? 0 : local.multi_azs}"
  subnet_id      = "${aws_subnet.pri_nat.*.id[count.index]}"
  route_table_id = "${aws_route_table.pri_nat.id}"
}
```

```HCL
resource "aws_subnet" "pri_nat" {
  count                   = "${var.nat == 0 ? 0 : local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs * 3)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pri-nat","SubnetRole","pri_nat"))}"
}
```

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
- db_subnet_group
### db_instance

- `enabled_cloudwatch_logs_exports` に`error`,`general`,`slowquery`を設定
- EnhancedMonitoringをonに設定

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
### parameter

- 大量にqueryを実行するために`max_prepqred_stmt_count`をmaxに設定
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

ec2
--
- ec2

### ec2 instance
rdsから各db_instanceのazを受け取ってdb_instanceと同じazのpublic subnetに同数のdata set投入用ec2を立てる
```HCL
output "mysql_azs" {
  value = [
    "${aws_db_instance.mysql56.*.availability_zone}",
    "${aws_db_instance.mysql57.*.availability_zone}",
    "${aws_db_instance.mysql80.*.availability_zone}",
    "${aws_db_instance.mariadb101.*.availability_zone}",
    "${aws_db_instance.mariadb102.*.availability_zone}",
    "${aws_db_instance.mariadb103.*.availability_zone}",
    "${aws_rds_cluster_instance.aurora56.*.availability_zone}",
    "${aws_rds_cluster_instance.aurora57.*.availability_zone}",
  ]
}
```

```HCL
data "aws_subnet" "pubs" {
  count             = "${length(data.terraform_remote_state.rds.mysql_azs)}"
  vpc_id            = "${data.aws_vpc.vpc.id}"
  availability_zone = "${element(data.terraform_remote_state.rds.mysql_azs,count.index)}"

  filter {
    name   = "tag:Name"
    values = ["${terraform.workspace}-pub"]
  }
}

resource "aws_instance" "ope" {
  count                  = "${length(data.terraform_remote_state.rds.mysql_azs)}"
  ami                    = "${data.aws_ami.amz2.id}"
  instance_type          = "${element(local.ec2_instance_tyeps,count.index)}"
  key_name               = "${data.terraform_remote_state.base.key_pair}"
  subnet_id              = "${data.aws_subnet.pubs.*.id[count.index]}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2.name}"
  user_data_base64       = "${base64encode(data.template_file.user_data_ec2.*.rendered[count.index])}"
  monitoring             = true
  tags                   = "${merge(local.tags, map("Name", "${terraform.workspace}-ope"))}"
}
```

### user_data

- install sysbench
```bash
#!/bin/bash

# packages
sudo yum -y install jq
sudo yum -y install git make automake libtool pkgconfig libaio-devel
sudo yum -y install mariadb-devel openssl-devel
sudo yum -y install postgresql-devel

cd /usr/local/src
# install sysbench
git clone https://github.com/akopytov/sysbench.git

cd sysbench

./autogen.sh
# Add --with-pgsql to build with PostgreSQL support
./configure
make -j
sudo make install

# install mysql-client
sudo yum -y install https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo yum -y install mysql
```

- script
config
```bash
cat <<'EOF' > config
db-driver=mysql
mysql-password=${password}
EOF
```

comm
```bash
cat <<'EOF' > comm
tbls=200
size=2000000
common="/usr/local/share/sysbench/oltp_common.lua"
EOF
```

prepare
```bash
cat <<'EOF' > prepare
#!/bin/env bash

. ./comm

sysbench \
--config-file=config \
--mysql-host=$1 \
--tables=$tbls \
--table-size=$size \
--threads=10 \
$${2:-$${common}} \
cleanup

sysbench \
--config-file=config \
--mysql-host=$1 \
--tables=$tbls \
--table-size=$size \
--threads=10 \
$${2:-$${common}} \
prepare
EOF
```

bench
```bash
cat <<'EOF' > bench
#!/bin/env bash

. ./comm

sysbench \
--config-file=config \
--mysql-host=$1 \
--tables=$tbls \
--table-size=$size \
$2 \
run
EOF
```

list
```bash
cat <<'EOF' > list
${list}
EOF
```

cleanup
```
cat <<'EOF' > cleanup
#!/bin/env bash

. ./comm

sysbench \
--config-file=config \
--mysql-host=$1 \
--tables=$tbls \
--table-size=$size \
$${2:-$${common}} \
cleanup
EOF
```
showtable
```
cat <<'EOF' > showtable
#!/bin/env bash

mysql -h $1 -usbtest --password=${password} sbtest -e 'select @@version' 2>/dev/null
mysql -h $1 -usbtest --password=${password} sbtest -e 'show tables' 2>/dev/null
mysql -h $1 -usbtest --password=${password} sbtest -e 'show create table sbtest1' 2>/dev/null
EOF
```

