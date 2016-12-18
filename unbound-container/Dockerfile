FROM koyama41/ubuntu14.04-unbound
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN mkdir -p /etc/unbound; (echo 'server:'; echo '  logfile: ""') > /etc/unbound/unbound.conf
ENTRYPOINT [ "/usr/sbin/unbound", "-d" ]
CMD [ "-v" ]
