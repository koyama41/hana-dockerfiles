FROM koyama41/ubuntu14.04-python-httpd
MAINTAINER KOYAMA Youichi <koyama41@gmail.com>
ADD hhh-v11n.conf /etc/apache2/sites-available
WORKDIR /etc/apache2/sites-enabled
RUN ln -s ../sites-available/hhh-v11n.conf .
RUN ln -s /opt/hhh-v11n/hhh_v11n_server/etcfiles/hhh /etc/hhh
ENTRYPOINT [ "/usr/sbin/apachectl", "-D", "FOREGROUND" ]
CMD []
