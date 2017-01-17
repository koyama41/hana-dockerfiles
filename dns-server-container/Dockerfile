FROM koyama41/ubuntu14.04-bind9
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN perl -i.bak -pe 's/^bind:x:\d+:\d+:/bind:x:1000:1000:/' /etc/passwd
RUN perl -i.bak -pe 's/^bind:x:\d+:/bind:x:1000:/' /etc/group
ENTRYPOINT [ "/usr/sbin/named" ]
CMD [ "-g", "-u", "bind" ]

