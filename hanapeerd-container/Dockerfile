FROM ubuntu:14.04
MAINTAINER KOYAMA Youichi <koyama@trans-nt.com>
WORKDIR /
COPY hanapeerd /usr/bin/
ENTRYPOINT [ "/usr/bin/hanapeerd" ]
CMD [ "-vv", "-c", "9999", "-s", "127.0.0.1/3000" ]
