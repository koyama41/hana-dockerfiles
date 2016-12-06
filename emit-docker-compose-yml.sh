#! /bin/sh

if [ "$1" != "" ]; then
  subnet_prefix=$1
  netid=$2
  hostid=$3
  shift
  shift
  shift
  vms="$@"
else
  subnet_prefix=10.87
  netid=87
  hostid=1
  vms="vm1 vm2 vm3"
fi

cat <<EOF
version: '2'

networks:
  maintainlink:
    external:
      name: hana-maintainlink

services:
EOF

for vmname in $vms
do
  cat << EOF
  $vmname:
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
    image: hana/unbound-container
    container_name: $vmname-unbound
    network_mode: "service:$vmname"

  $vmname-hanad:
    image: hana/hanad-container
    container_name: $vmname-hanad
    network_mode: "service:$vmname"

  $vmname-hanapeerd:
    image: hana/hanapeerd-container
    container_name: $vmname-hanapeerd
    network_mode: "service:$vmname"

  $vmname-hanaroute:
    image: hana/hanaroute-container
    container_name: $vmname-hanaroute
    network_mode: "service:$vmname"
    depends_on:
      - $vmname-hanad
    cap_add:
      - NET_ADMIN

  $vmname-hanansupdate:
    image: hana/hanansupdate-container
    container_name: $vmname-hanansupdate
    network_mode: "service:$vmname"
    depends_on:
      - $vmname-hanad
EOF

  if [ "$vmname" = "vm0" ]; then
    # special case:
    cat <<EOF
  $vmname-dns-server:
    image: hana/dns-server-container
    container_name: $vmname-dns-server
    network_mode: "service:$vmname"
    cap_add:
      - NET_RAW
      - NET_BIND_SERVICE

  $vmname-hanavis-server:
    image: hana/hanavis-server-container
    container_name: $vmname-hanavis-server
    network_mode: "service:$vmname"
EOF

  fi
  hostid=`expr $hostid + 1`
done
