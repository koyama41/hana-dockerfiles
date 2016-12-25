FROM koyama41/ubuntu14.04-unbound
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN mkdir -p /etc/unbound
ADD unbound.conf /etc/unbound
ENTRYPOINT [ "/usr/sbin/unbound", "-d" ]
CMD [ "-v" ]
