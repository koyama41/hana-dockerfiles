FROM koyama41/ubuntu14.04-python-httpd
MAINTAINER KOYAMA Youichi <koyama41@gmail.com>
RUN mkdir -p /opt/hhh-v11n
WORKDIR /opt/hhh-v11n
ADD hhh_v11n_server-3.4.tar.gz /opt/hhh-v11n
RUN ln -s hhh_v11n_server-3.4 hhh_v11n_server
WORKDIR /opt/hhh-v11n/hhh_v11n_server
RUN make setup
WORKDIR /opt/hhh-v11n/hhh_v11n_server/etcfiles/hhh
RUN mv hhh_v11n_server.conf.sample hhh_v11n_server.conf
RUN mv hhh_v11n_observatory.conf.sample hhh_v11n_observatory.conf
RUN echo 'BROADCASTER_LISTEN_ADDR=0.0.0.0:8081' > hhh_v11n_broadcaster.conf
VOLUME /opt
RUN ln -s /opt/hhh-v11n/hhh_v11n_server/etcfiles/hhh /etc/hhh
CMD [ "/bin/sh" ]
