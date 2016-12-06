FROM koyama41/ubuntu14.04-dnsutils
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
COPY hanansupdate /usr/bin/
ENTRYPOINT [ "/usr/bin/hanansupdate" ]
CMD [ "-v", "127.0.0.1", "3000" ]
