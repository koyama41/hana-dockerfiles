FROM koyama41/python2.7-django-apache2
MAINTAINER KOYAMA Youichi <koyama41@gmail.com>
ADD hhh-v11n.conf /etc/apache2/sites-available
WORKDIR /etc/apache2/sites-enabled
RUN ln -s ../sites-available/hhh-v11n.conf .
ENTRYPOINT [ "/usr/sbin/apachectl", "-D", "FOREGROUND" ]
CMD []
