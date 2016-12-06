#! /bin/sh

: ${DOCKER:="sudo docker"}
: ${DOCKER_COMPOSE:="sudo docker-compose"}
: ${DOCKER_COMPOSE_YML:="docker-compose.yml"}
: ${BRCTL_ADDIF:="sudo brctl addif"}
: ${HANA_LINKNAMES:="upper lower"}
: ${IPCMD_NOSUDO:="ip"}

hana_maintainlink_interface=XXX0
hana_upperlink_interface=XXX1

workdir=`dirname $0`

netaddr_for_maintainlink=10.87
netaddr_for_upperlink=10.88
netaddr_for_lowerlink=10.89

retry_max=3

(cd $workdir; $DOCKER_COMPOSE stop)

images=`$(DOCKER) ps -a -q`
if [ "$images" != "" ]; then $(DOCKER) rm $images; fi

for name in maintain $HANA_LINKNAMES
do
  if $DOCKER network inspect hana-${name}link >/dev/null 2>&1; then
    echo -n "REMOVE: "
    $DOCKER network rm hana-${name}link
  fi

  eval netaddr=\$netaddr_for_${name}link
  echo -n "CREATE: "
  $DOCKER network create -d bridge \
                         --subnet=${netaddr}.0.0/16 \
                         --gateway=${netaddr}.255.254 \
                         hana-${name}link
  eval physical_interface=\$hana_${name}link_interface
  if [ "$physical_interface" != "" ]; then
    if $IPCMD_NOSUDO link show $physical_interface >/dev/null 2>&1; then
      ip -f inet --oneline address show | while read num brname inet addr rest
      do
        case $addr in
          ${first_octet}.${second_octet}.255.254/16)
            echo JOIN: $physical_interface to hana-${name}link: $brname
            $BRCTL_ADDIF $brname $physical_interface;;
        esac
      done
    fi
  fi
  second_octet=`expr $second_octet + 1`
done

(cd $workdir
 force_recreate=--force-recreate
 while true
 do
   if $DOCKER_COMPOSE up -d $force_recreate; then
     break
   fi
   retry_max=`expr $retry_max - 1`
   if [ $retry_max = 0 ]; then
     break
   fi
   echo ''
   #force_recreate=''
   echo "### RETRY $DOCKER_COMPOSE up -d $force_recreate"
 done)

(cd $workdir;
 container_name=''
 IFS=' :'
 while read key value other
 do
   case $key in
     container_name) container_name=$value;;
     ipv4_address)
       hostaddr=${value#*.*.}
       if [ "$container_name" != "" ]; then
         for name in $HANA_LINKNAMES
         do
           eval netaddr=\$netaddr_for_${name}link
           $DOCKER network connect --ip ${netaddr}.${hostaddr} \
		                   hana-${name}link $container_name
         done
       fi
       ;;
   esac
 done ) < $DOCKER_COMPOSE_YML
