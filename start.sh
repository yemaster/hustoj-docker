#!/bin/sh

# 判断 data 目录是否存在
if [ ! -d "data" ]; then
    echo "创建 data 目录..."
    mkdir data
fi

if [ ! -d "data/mysql" ] || [ ! -d "data/web" ] || [ ! -d "data/judger/data" ]; then
    echo "创建子目录..."
    mkdir -p data/mysql data/web data/judger/data
    curl https://raw.githubusercontent.com/zhblue/hustoj/refs/heads/master/trunk/install/db.sql -o ./db.sql
fi

chmod -R 777 data

docker-compose up -d