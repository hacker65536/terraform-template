#!/bin/bash



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

# if amz2 and need login
sudo amazon-linux-extras install -y vim

#cd /home/ec2-user
cd /root
cat <<'EOF' > config
db-driver=mysql
mysql-password=${password}
EOF


cat <<'EOF' > comm
tbls=200
size=2000000
common="/usr/local/share/sysbench/oltp_common.lua"
EOF

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

cat <<'EOF' > list
${list}
EOF

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

cat <<'EOF' > showtable
#!/bin/env bash

mysql -h $1 -usbtest --password=${password} sbtest -e 'select @@version' 2>/dev/null
mysql -h $1 -usbtest --password=${password} sbtest -e 'show tables' 2>/dev/null
mysql -h $1 -usbtest --password=${password} sbtest -e 'show create table sbtest1' 2>/dev/null
EOF

cat <<'EOF' > read_only.lua
#!/usr/bin/env sysbench

require("oltp_read_only")

require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF



cat <<'EOF' > read_write.lua
#!/usr/bin/env sysbench

require("oltp_read_write")

require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF


cat <<'EOF' > write_only.lua
#!/usr/bin/env sysbench

require("oltp_write_only")

require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF


cat <<'EOF' > update_index.lua
#!/usr/bin/env sysbench

require("oltp_update_index")

require("json")
sysbench.hooks.report_cumulative = sysbench.report_json
EOF

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


sudo amazon-linux-extras install -y docker
sudo systemctl start docker


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
#declare -a hostary=(
#"rds-comp2-aurora56.cluster-ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-aurora57.cluster-ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mariadb10114.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mariadb10134.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mariadb10215.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mysql5639.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mysql5640.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#"rds-comp2-mysql5722.ccm7kbox0as4.us-west-2.rds.amazonaws.com"
#)


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
