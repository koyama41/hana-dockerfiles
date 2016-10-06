FROM koyama41/ubuntu14.04-sshd
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/
ENTRYPOINT [ "/usr/sbin/sshd", "-D", "-e" ]
CMD [ ]