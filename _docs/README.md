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

user_dataはsysbenchのコマンド操作がほとんどのため、worker_ec2とほぼ同じ

- sysbenchのinstallとsysbenchのコマンドをwrapしたscript
- sysbenchの結果出力を簡易に集計できるようにするためにjsonフォーマットに変更、repost_json関数作成して整形を行う


通常の出力フォーマット
```
$ sysbench --test=oltp --db-driver=mysql --mysql-password=sbtest run
sysbench 0.4.12:  multi-threaded system evaluation benchmark

Running the test with following options:
Number of threads: 1

Doing OLTP test.
Running mixed OLTP test
Using Special distribution (12 iterations,  1 pct of values are returned in 75 pct cases)
Using "BEGIN" for starting transactions
Using auto_inc on the id column
Maximum number of requests for OLTP test is limited to 10000
Threads started!
Done.

OLTP test statistics:
    queries performed:
        read:                            140000
        write:                           50000
        other:                           20000
        total:                           210000
    transactions:                        10000  (25.72 per sec.)
    deadlocks:                           0      (0.00 per sec.)
    read/write requests:                 190000 (488.63 per sec.)
    other operations:                    20000  (51.43 per sec.)

Test execution summary:
    total time:                          388.8436s
    total number of events:              10000
    total time taken by event execution: 388.7773
    per-request statistics:
         min:                                 28.61ms
         avg:                                 38.88ms
         max:                                178.72ms
         approx.  95 percentile:              44.83ms

Threads fairness:
    events (avg/stddev):           10000.0000/0.00
    execution time (avg/stddev):   388.7773/0.00
```

jsonフォーマット
```json
{
    "qp": {
        "reads": 0,
        "writes": 2738411,
        "other": 0,
        "total": 2738411
    },
    "trx": 2738411,
    "err": 0,
    "recon": 0,
    "timetotal": 1801.7208,
    "tps": 1519.8864,
    "latency": {
        "min": 0.002261744,
        "avg": 0.065793314,
        "max": 3.812709558,
        "pct": 0.1899294783,
        "sum": 180169.136323044
    }
}
```

#### install sysbench
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

#### script

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
#### sysbench test json output(lua)

read_only
```bash
cat <<'EOF' > read_only.lua
#!/usr/bin/env sysbench

require("oltp_read_only")
require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF
```
read_write
```bash
cat <<'EOF' > read_write.lua
#!/usr/bin/env sysbench

require("oltp_read_write")
require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF
```
write_only
```bash
cat <<'EOF' > write_only.lua
#!/usr/bin/env sysbench

require("oltp_write_only")
require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF
```
update_index
```bash
cat <<'EOF' > update_index.lua
#!/usr/bin/env sysbench

require("oltp_update_index")
require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF
```

json.lua
```bash
cat <<'EOF'> json.lua
function sysbench.report_json(stat)
   if not gobj then
      io.write('')
      -- hack to print the closing bracket when the Lua state of the reporting
      -- thread is closed
      gobj = newproxy(true)
      getmetatable(gobj).__gc = function () io.write('') end
   else
      io.write(',\n')
   end

   local seconds = stat.time_interval
   io.write(([[
{
  "qp": {
    "reads": %d,
    "writes": %d,
    "other": %d,
    "total": %d
  },
  "trx": %d,
  "err": %d,
  "recon": %d,
  "timetotal": %.4f,
  "tps": %.4f,
  "latency": {
    "min": %4.10f,
    "avg": %4.10f,
    "max": %4.10f,
    "pct": %4.10f,
    "sum": %4.10f
  }
}
]]):format(
        stat.reads,
        stat.writes,
        stat.other,
        stat.reads + stat.writes + stat.other,

        stat.events,
        stat.errors ,
        stat.reconnects,
        stat.time_total,
        stat.events / seconds,

        stat.latency_min,
        stat.latency_avg,
        stat.latency_max,
        stat.latency_pct,
        stat.latency_sum
   ))
end
EOF
```

#### parameter list

```bash
mkdir docker
cat <<'EOF' > docker/Dockerfile
From mysql:8


add rds-* /usr/local/src/
add my.cnf /etc/mysql/
EOF

cat <<'EOF' > docker/outputparam2.sh
#!/bin/bash

dir="params"
mkdir -p ./$dir
prefix="tformtmp5-"

#"tformtmp5--aurora56.cluster-ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--aurora57.cluster-ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mariadb10114.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mariadb10134.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mariadb10215.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mysql5639.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mysql5640.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"tformtmp5--mysql5722.ccm7kbox0as4.us-west-2.rds.amazonaws.com"


for host in $(cat ../list)
do
tmp=$${host%%.*}
mysql -u sbtest -pfoobarbaz -h $host -s -e "show variables" >  $dir/$${tmp#$prefix}
done



docker run --rm -d --name mysql8  -e MYSQL_ROOT_PASSWORD=my8pass -p 3306:3306  mysql:8
docker exec -it -w /etc/mysql mysql8 sed -i 's/^\(secure-file-priv\).*/\1= ""/' my.cnf
sleep 3
docker kill -s HUP mysql8
sleep 10
mysqladmin -uroot -pmy8pass -h 127.0.0.1 create testdb
docker cp ./$dir mysql8:/usr/local/src

mysql -uroot -pmy8pass -h 127.0.0.1 -e "create table if not exists mysql ( name varchar(255), primary key(name))" testdb

for table in $(ls $dir)
do
mysql -uroot -pmy8pass -h 127.0.0.1 -e "create table if not exists $table ( name varchar(255),value text, primary key(name))" testdb
mysql -uroot -pmy8pass -h 127.0.0.1 -e "LOAD DATA INFILE '/usr/local/src/$dir/$table' INTO table $table" testdb
mysql -uroot -pmy8pass -h 127.0.0.1 -e "replace into mysql(name) select name from $table;" testdb
#echo $table
done

:>sql
col="mysql.name, "
col2="'param', "
for table in $(ls $dir)
do
echo "left outer join $${table} on mysql.name=$${table}.name ">>sql
col+="$${table}.value as $${table}, "
col2+="'$${table}', "
done

echo " INTO OUTFILE '/tmp/rds-param-comp.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'">>sql
sed "1i select $${col%, } from mysql " -i sql
sed "1i select $${col2%, } union " -i sql

mysql -uroot -pmy8pass -h 127.0.0.1 testdb <sql

docker cp mysql8:/tmp/rds-param-comp.csv ./rds-param-comp.csv
docker stop mysql8
EOF
```

worker_ec2
--
- spot_fleet
- ssm_doc

### spot fleet

- spot priceはinstance type毎の1/3を目安に設定
- db毎に3台をそれぞれのazで立てる(レイテンシの平準化)
- db毎のinstancesにtagを使ってgrouping

```HCL
locals {
  spot_price {
    c5.large   = "0.1"
    c5.xlarge  = "0.3"
    c5.2xlarge = "0.3"
    t2.micro   = "0.01"
    t2.medium  = "0.02"
  }
}

locals {
  rdss = "${length(data.terraform_remote_state.rds.mysql_addresses)}"
  azs  = "${length(data.aws_availability_zones.azs.names)}"
}

output "rdss" {
  value = "${data.terraform_remote_state.rds.mysql_addresses}"
}

# Request a Spot fleet
resource "aws_spot_fleet_request" "cheap_compute" {
  count = "${local.rdss * local.azs}"

  iam_fleet_role      = "${aws_iam_role.fleet.arn}"
  allocation_strategy = "lowestPrice"
  target_capacity     = 1
  valid_until         = "2019-11-04T20:44:20Z"

  // maintain = persisitent  request = one-time
  // spot instance  one-time(default) persistent
  // spot fleet     reqeust  maintain(default)
  fleet_type = "request"

  terminate_instances_with_expiration = true

  launch_specification {
    instance_type            = "${local.ec2_instance_type}"
    ami                      = "${data.aws_ami.amz2.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "${local.spot_price["${local.ec2_instance_type}"]}"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ec2.rendered)}"
    subnet_id                = "${data.aws_subnet_ids.pub.ids[count.index % local.azs]}"
    vpc_security_group_ids   = ["${data.aws_security_group.sec.id}"]
    weighted_capacity        = 1

    tags = "${merge(
      local.tags,
        map(
          "Name", "${terraform.workspace}-ec2node-sf",
          "groupName","${terraform.workspace}-sf-${count.index / local.azs}"
        )
    )}"
  }
}
```
### ssm

amazonlinux2 を利用しているためssm agentはデフォルトで起動している前提

- sysbenchのコマンドをruncommandを利用して一斉制御を行う
- sysbenchの出力をcloudwatchlogsに出力をする
- sysbenchの実行コマンドをssm documentを利用してwrap



```HCL
data "template_file" "ssmdoc" {
  template = "${file("ssmdoc.json")}"
}

resource "aws_ssm_document" "ssmdoc" {
  name          = "${terraform.workspace}-sysbench"
  document_type = "Command"
  content       = "${data.template_file.ssmdoc.rendered}"
}
```
```json
{
  "schemaVersion": "2.2",
  "description": "sysbench",
  "parameters": {
    "user": {
      "description": "dbuser",
      "type": "String",
      "default": "sbtest"
    },
    "pass": {
      "description": "dbpassword",
      "type": "String",
      "default": "foobarbaz"
    },
    "host": {
      "description": "dbhost",
      "type": "String",
      "default": ""
    },
    "schema": {
      "description": "dbname",
      "type": "String",
      "default": "sbtest"
    },
    "threads": {
      "description": "threads",
      "type": "String",
      "default": "1"
    },
    "time": {
      "description": "time",
      "type": "String",
      "default": "10"
    },
    "testname": {
      "description": "testname",
      "type": "String",
      "default": "/usr/local/share/sysbench/oltp_read_write.lua"
    },
    "command": {
      "description": "command",
      "type": "String",
      "default": "run"
    }
  },
  "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "sysbench",
      "precondition": {
        "StringEquals": [
          "platformType",
          "Linux"
        ]
      },
      "inputs": {
        "runCommand": [
          "sysbench --db-driver=mysql --mysql-host={{host}} --mysql-user={{user}} --mysql-password={{pass} --mysql-db={{schema}} --threads={{threads}} --time={{time}} {{testname}} {{command}}"
        ],
        "workingDirectory": "/root"
      }
    }
  ]
}
```


tools
--

