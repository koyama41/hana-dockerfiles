FROM ubuntu:14.04
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
COPY hanaroute /usr/bin/
ENTRYPOINT [ "/usr/bin/hanaroute" ]
CMD [ "-vv", "-r", "127.0.0.1", "3000" ]
