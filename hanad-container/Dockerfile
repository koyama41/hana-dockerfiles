FROM ubuntu:14.04
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
COPY hanad /usr/bin/
ENTRYPOINT [ "/usr/bin/hanad" ]
CMD [ "-v", "7", "-a", "500,100/100000", "3000" ]
