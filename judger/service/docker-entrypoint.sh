#!/bin/bash

# 判断是否有 INSTALL 环境变量，没有就直接退出
if [ -z "$INSTALL" ]; then
    echo "INSTALL environment variable is not set. Exiting."
    sleep infinity
    exit 1
fi

# 安装 docker
apt update && apt install -y docker.io --no-install-recommends && rm -rf /var/lib/apt/lists/*

# 判断 installed 文件是否存在
if [ ! -f /home/judge/.hustoj_installed ]; then
    echo "First time setup..."
    touch /home/judge/.hustoj_installed
    cp -r /opt/judger/* /home/judge/
    chmod -R 700 /home/judge
    chmod -R 777 /home/judge/data
    chown -R judge:judge /home/judge
fi

# 修改配置文件
if [ -n "$DB_HOST" ]; then
    echo "OJ_HOST_NAME is set to $DB_HOST"
    sed -i "s/OJ_HOST_NAME=.*/OJ_HOST_NAME=$DB_HOST/g" /home/judge/etc/judge.conf
fi

if [ -n "$DB_USER" ]; then
    echo "OJ_USER_NAME is set to $DB_USER"
    sed -i "s/OJ_USER_NAME=.*/OJ_USER_NAME=$DB_USER/g" /home/judge/etc/judge.conf
fi

if [ -n "$DB_PASS" ]; then
    echo "OJ_PASSWORD is set to $DB_PASS"
    sed -i "s/OJ_PASSWORD=.*/OJ_PASSWORD=$DB_PASS/g" /home/judge/etc/judge.conf
fi

if [ -n "$DB_NAME" ]; then
    echo "OJ_DB_NAME is set to $DB_NAME"
    sed -i "s/OJ_DB_NAME=.*/OJ_DB_NAME=$DB_NAME/g" /home/judge/etc/judge.conf
fi

sed -i "s/OJ_TIME_LIMIT_TO_TOTAL=1/OJ_TIME_LIMIT_TO_TOTAL=0/g" /home/judge/etc/judge.conf
sed -i "s/OJ_USE_DOCKER=0/OJ_USE_DOCKER=1/g" /home/judge/etc/judge.conf
sed -i "s/OJ_PYTHON_FREE=0/OJ_PYTHON_FREE=1/g" /home/judge/etc/judge.conf
sed -i "s|OJ_DOCKER_PATH=/usr/bin/podman|OJ_DOCKER_PATH=/usr/bin/docker|g" /home/judge/etc/judge.conf
sed -i "s/OJ_UDP_SERVER=.*/OJ_UDP_SERVER=judger/g" /home/judge/etc/judge.conf

/usr/bin/judged /home/judge DEBUG

sleep infinity