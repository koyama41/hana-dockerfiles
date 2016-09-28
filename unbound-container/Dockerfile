FROM ubuntu:14.04
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN apt-get update
RUN apt-get -y install unbound
RUN mkdir -p /etc/unbound; (echo 'server:'; echo '  logfile: ""') > /etc/unbound/unbound.conf
ENTRYPOINT [ "/usr/sbin/unbound", "-d" ]
CMD [ "-v" ]