#! /bin/sh

: ${VMS_DIR:=$HOME/HANA-docker-vms}

if [ "$1" != "" ]; then
  netid=$1
else
  netid=87
fi

hostid_start=1
hostid_end=20
scriptdir=`dirname $0`

for hostid in `seq $hostid_start $hostid_end`
do
  mkdir -p $VMS_DIR/vm$hostid
  sh $scriptdir/emit-docker-compose-yml.sh 10.87 $netid $hostid vm$hostid \
      > $VMS_DIR/vm$hostid/docker-compose.yml
done
