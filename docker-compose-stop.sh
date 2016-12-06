#! /bin/sh

: ${DOCKER:="sudo docker"}
: ${DOCKER_COMPOSE:="sudo docker-compose"}
: ${DOCKER_COMPOSE_YML:="docker-compose.yml"}
: ${HANA_LINKNAMES:="upper lower"}
: ${VMDIRS:="vm? vm??"}

workdir=`dirname $0`

cd $workdir

for i in $VMDIRS
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
