#!/bin/bash

sudo apt install gnupg postgresql-common apt-transport-https lsb-release wget

sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh

sudo apt install postgresql-server-dev-16

echo "deb https://packagecloud.io/timescale/timescaledb/ubuntu/ $(lsb_release -c -s) main" | sudo tee /etc/apt/sources.list.d/timescaledb.list]

wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/timescaledb.gpg

sudo apt update

sudo apt install timescaledb-2-postgresql-16 postgresql-client-16

sudo timescaledb-tune

sudo systemctl restart postgresql

sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS timescaledb;"

echo "tsdb deploy success!"

#添加远程登录
pg_hbaconf_path=$(find / -wholename "*/pg_hba.conf")
if [ -n "$pg_hbaconf_path" ];then
        echo "find pg_hba.conf!"
else
        echo "pg_hbaconf_path dont exist!"
fi
echo "host    tsdb            all             0.0.0.0/0               password" | sudo tee -a "$pg_hbaconf_path"

#修改监听地址
address_line_num=60
psqlconf_path=$(find / -wholename "*/postgresql.conf" -print -quit)
if [ -n "$psqlconf_path" ]; then
    echo "find postgresql.conf!"
    sed -i "${address_line_num}s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" ${psqlconf_path}
    if [ $? -eq 0 ]; then
        echo "modify address success!"
    else
        echo "modify address failed!"
    fi
else
    echo "postgresql.conf dont exist!"
fi

#重启pgsql服务
sudo systemctl restart postgresql

#登录pgsql创建用户并授权
sudo -u postgres psql <<EOF

CREATE USER egate_pool WITH PASSWORD 'iot123';
CREATE DATABASE tsdb WITH OWNER egate_pool;
\c tsdb;
GRANT CREATE ON SCHEMA public TO egate_pool;
EOF
