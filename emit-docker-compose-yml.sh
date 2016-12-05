#! /bin/sh

if [ "$1" != "" ]; then
  subnet_prefix=$1
  netid=$2
  shift
  vms="$@"
else
  subnet_prefix=10.87
  netid=87
  vms="vm1 vm2"
fi

cat <<EOF
version: '2'

networks:
  maintainlink:
    external:
      name: hana-maintainlink

services:
EOF

hostid=1
for vmname in $vms
do
  cat << EOF
  $vmname:
    build: sshd-container
    image: hana/sshd-container
    container_name: $vmname
    networks:
      maintainlink:
        ipv4_address: $subnet_prefix.$netid.$hostid
    hostname: $vmname
    dns: 127.0.0.1
    cap_add:
      - NET_RAW
      - NET_ADMIN
      - NET_BIND_SERVICE

  $vmname-unbound:
    build: unbound-container
    image: hana/unbound-container
    container_name: $vmname-unbound
    network_mode: "service:$vmname"

  $vmname-hanad:
    build: hanad-container
    image: hana/hanad-container
    container_name: $vmname-hanad
    network_mode: "service:$vmname"

  $vmname-hanapeerd:
    build: hanapeerd-container
    image: hana/hanapeerd-container
    container_name: $vmname-hanapeerd
    network_mode: "service:$vmname"

  $vmname-hanaroute:
    build: hanaroute-container
    image: hana/hanaroute-container
    container_name: $vmname-hanaroute
    network_mode: "service:$vmname"
    depends_on:
      - $vmname-hanad
    cap_add:
      - NET_ADMIN

  $vmname-hanansupdate:
    build: hanansupdate-container
    image: hana/hanansupdate-container
    container_name: $vmname-hanansupdate
    network_mode: "service:$vmname"
    depends_on:
      - $vmname-hanad
EOF
hostid=`expr $hostid + 1`
done
