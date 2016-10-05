FROM ubuntu:14.04
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install openssh-server
RUN mkdir /var/run/sshd
RUN mkdir /root/.ssh
COPY authorized_keys /root/.ssh/
ENTRYPOINT [ "/usr/sbin/sshd", "-D", "-e" ]
CMD [ ]