FROM php:8.1-fpm-alpine

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

RUN apk add --update --no-cache nginx bash libmemcached-dev libpng-dev libzip-dev zlib-dev yaml-dev autoconf g++ make

RUN sed -i "$ s/\-n//g" /usr/local/bin/pecl

RUN pecl channel-update pecl.php.net && \
    pecl install memcached yaml memcache && \
    docker-php-ext-enable memcached yaml memcache

RUN docker-php-source extract && \
    docker-php-ext-install pdo_mysql mysqli gd zip sockets && \
    docker-php-source delete

RUN apk del autoconf g++ make && \
    rm -rf /tmp/pear /var/cache/apk/*

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/docker-php-ext-mysqli.ini /usr/local/etc/php/conf.d
COPY ./config/docker-php-ext-pdo_mysql.ini /usr/local/etc/php/conf.d
COPY ./config/php.ini /usr/local/etc/php/php.ini

COPY src /opt/www

COPY ./service/docker-entrypoint.sh /etc/init.sh
RUN chmod +x /etc/init.sh

WORKDIR /var/www/html
EXPOSE 80

CMD ["/etc/init.sh"]