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

cat <<'EOF' > prepare
#!/bin/env bash

sysbench \
--config-file=config \
--mysql-host=$1 \
/usr/local/share/sysbench/oltp_read_only.lua \
prepare
EOF

cat <<'EOF' > bench
#!/bin/env bash

sysbench \
--config-file=config \
--mysql-host=$1 \
/usr/local/share/sysbench/oltp_read_write.lua \
run
EOF

#chown -R ec2-user:ec2-user /home/ec2-user/
