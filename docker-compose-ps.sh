#! /bin/sh

: ${DOCKER:="sudo docker"}
: ${DOCKER_COMPOSE:="sudo docker-compose"}
: ${DOCKER_COMPOSE_YML:="docker-compose.yml"}
: ${VMS_DIR:=$HOME/HANA-docker-vms}
: ${VMS_SUBDIRS:="vm? vm??"}

cd $VMS_DIR

if [ "$1" != "" ]; then
  VMS_SUBDIRS="$@"
fi

for i in $VMS_SUBDIRS
do
  if [ -x $i/$DOCKER_COMPOSE_YML ]; then  # use -x instead of -e: XBITHACK
    (cd $i
     echo -n "checking $i ..."
     docker-compose ps | grep ^vm | grep -v Up || echo "checking $i ... OK"
    )
  fi
done

