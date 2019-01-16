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

cat <<'EOF' > list
${list}
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

cat <<'EOF' > point_select.lua
#!/usr/bin/env sysbench

require("oltp_point_select")

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
