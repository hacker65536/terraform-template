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
tbls=10
size=100000
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
$${2:-$${common}} \
cleanup

sysbench \
--config-file=config \
--mysql-host=$1 \
--tables=$tbls \
--table-size=$size \
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
