#! /bin/sh

if [ "$1" != "" ]; then
  netid=$1
else
  netid=87
fi

hostid_start=1
hostid_end=20
workdir=`dirname $0`

for hostid in `seq $hostid_start $hostid_end`
do
  mkdir -p vm$hostid
  sh $workdir/emit-docker-compose-yml.sh 10.87 $netid $hostid vm$hostid \
      > vm$hostid/docker-compose.yml
done
