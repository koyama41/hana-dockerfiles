FROM mysql
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
ENV MYSQL_DATABASE=hhh_v11n_django MYSQL_USER=hhh MYSQL_PASSWORD=hhhpass MYSQL_ROOT_PASSWORD=rootpass
COPY hanavis.cnf /etc/mysql/conf.d/
VOLUME /var/run/mysqld
