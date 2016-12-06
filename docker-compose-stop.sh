#! /bin/sh

: ${DOCKER:="sudo docker"}
: ${DOCKER_COMPOSE:="sudo docker-compose"}
: ${DOCKER_COMPOSE_YML:="docker-compose.yml"}
: ${HANA_LINKNAMES:="upper lower"}
: ${VMS_DIR:=$HOME/HANA-docker-vms}
: ${VMS_SUBDIRS:="vm? vm??"}

mkdir -p $VMS_DIR
cd $VMS_DIR

for i in $VMS_SUBDIRS
do
  if [ -e $i/$DOCKER_COMPOSE_YML ]; then (cd $i; $DOCKER_COMPOSE stop); fi
done

images=`$DOCKER ps -a -q`
if [ "$images" != "" ]; then $DOCKER rm $images; fi

for name in maintain $HANA_LINKNAMES
do
  if $DOCKER network inspect hana-${name}link >/dev/null 2>&1; then
    echo -n "REMOVE: "
    $DOCKER network rm hana-${name}link
  fi
done
