FROM python:2.7
ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt
ADD . /code/
RUN mkdir -p /opt/hhh-v11n
WORKDIR /opt/hhh-v11n
ADD hhh_v11n_server-3.4.tar.gz /opt/hhh-v11n
RUN ln -s hhh_v11n_server-3.4 hhh_v11n_server
VOLUME /opt
CMD [ "/bin/sh" ]
