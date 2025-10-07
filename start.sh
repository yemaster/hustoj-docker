#!/bin/sh
mkdir -p data/mysql data/web data/judger/data
chmod -R 777 data
# curl https://raw.githubusercontent.com/zhblue/hustoj/refs/heads/master/trunk/install/db.sql -o ./db.sql

docker-compose up -d