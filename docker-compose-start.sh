#! /bin/sh

: ${DOCKER:="sudo docker"}
: ${DOCKER_COMPOSE:="sudo docker-compose"}
: ${DOCKER_COMPOSE_YML:="docker-compose.yml"}
: ${BRCTL_ADDIF:="sudo brctl addif"}
: ${HANA_LINKNAMES:="upper lower"}
: ${IPCMD_NOSUDO:="ip"}
: ${VMS_DIR:=$HOME/HANA-docker-vms}
: ${VMS_SUBDIRS:="vm? vm??"}

hana_maintainlink_interface=XXX0
hana_upperlink_interface=XXX1

netaddr_for_maintainlink=10.87
netaddr_for_upperlink=10.88
netaddr_for_lowerlink=10.89

retry_max=3

mkdir -p $VMS_DIR
cd $VMS_DIR

for name in maintain $HANA_LINKNAMES
do
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

for i in $VMS_SUBDIRS
do
  if [ -e $i/$DOCKER_COMPOSE_YML ]; then
    ( cd $i
      force_recreate=--force-recreate
      retry_count=0
      while true
      do
        if $DOCKER_COMPOSE up -d $force_recreate; then
          break
        fi
        retry_count=`expr $retry_count + 1`
        if [ $retry_count -ge $retry_max ]; then
          break
        fi
        #force_recreate=''
        echo ''
        echo "### RETRY $DOCKER_COMPOSE up -d $force_recreate"
      done
    )
    ( container_name=''
      IFS=' :'
      while read key value other
      do
        case $key in
          container_name)
            container_name=$value
            ;;
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
      done
    ) < $i/$DOCKER_COMPOSE_YML
  fi
done

