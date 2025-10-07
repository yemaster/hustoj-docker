#!/bin/bash

# 判断 /var/www/html 是否有内容，为空则复制初始文件
if [ -z "$(ls -A /var/www/html)" ]; then
    cp -r /opt/www/* /var/www/html/
    echo "Copied initial web files to /var/www/html"
else
    echo "/var/www/html is not empty, skipping copy."
fi

chmod -R 777 /var/www/judger/data

sed -i "s/OJ_DATA[[:space:]]*=[[:space:]]*\".*\"/OJ_DATA=\"\/var\/www\/judger\/data\"/g" /var/www/html/include/db_info.inc.php;
sed -i "s/OJ_UDPSERVER[[:space:]]*=[[:space:]]*\".*\"/OJ_UDPSERVER=\"judger\"/g" /var/www/html/include/db_info.inc.php;

echo "Starting with the following environment variables:"
echo "DB_HOST is $DB_HOST"
echo "DB_USER is $DB_USER"
echo "DB_PASS is $DB_PASS"
echo "DB_NAME is $DB_NAME"
echo "HUSTOJ_NAME is $HUSTOJ_NAME"
echo "HUSTOJ_THEME is $HUSTOJ_THEME"

# 修改配置文件
if [ -n "$DB_HOST" ]; then
    echo "DB_HOST is set to $DB_HOST"
    sed -i "s/DB_HOST[[:space:]]*=[[:space:]]*\".*\"/DB_HOST=\"$DB_HOST\"/g" /var/www/html/include/db_info.inc.php
fi

if [ -n "$DB_USER" ]; then
    echo "DB_USER is set to $DB_USER"
    sed -i "s/DB_USER[[:space:]]*=[[:space:]]*\".*\"/DB_USER=\"$DB_USER\"/g" /var/www/html/include/db_info.inc.php
fi

if [ -n "$DB_PASS" ]; then
    echo "DB_PASS is set to $DB_PASS"
    sed -i "s/DB_PASS[[:space:]]*=[[:space:]]*\".*\"/DB_PASS=\"$DB_PASS\"/g" /var/www/html/include/db_info.inc.php
fi

if [ -n "$DB_NAME" ]; then
    echo "DB_NAME is set to $DB_NAME"
    sed -i "s/DB_NAME[[:space:]]*=[[:space:]]*\".*\"/DB_NAME=\"$DB_NAME\"/g" /var/www/html/include/db_info.inc.php
fi

if [ -n "$HUSTOJ_NAME" ]; then
    echo "HUSTOJ_NAME is set to $HUSTOJ_NAME"
    sed -i "s/OJ_NAME[[:space:]]*=[[:space:]]*\".*\"/OJ_NAME=\"$HUSTOJ_NAME\"/g" /var/www/html/include/db_info.inc.php
fi

if [ -n "$HUSTOJ_THEME" ]; then
    echo "HUSTOJ_THEME is set to $HUSTOJ_THEME"
    sed -i "s/OJ_TEMPLATE[[:space:]]*=[[:space:]]*\".*\"/OJ_TEMPLATE=\"$HUSTOJ_THEME\"/g" /var/www/html/include/db_info.inc.php
fi

chown -R www-data:www-data /var/www/html

php-fpm & nginx &

echo "Running..."

tail -F /var/log/nginx/access.log /var/log/nginx/error.log