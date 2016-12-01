#! /bin/sh

cat <<EOF
version: '2'

networks:
  upperlink:
    driver: bridge
    ipam: # we want to use "null" driver, but it is broken...
      driver: default
      config:
        - subnet: 192.168.87.0/24
          gateway: 192.168.87.254
  lowerlink:
    driver: bridge
    ipam: # we want to use "null" driver, but it is broken...
      driver: default
      config:
        - subnet: 192.168.88.0/24
          gateway: 192.168.88.254
  maintainlink:
    driver: bridge
    ipam: # we want to use "null" driver, but it is broken...
      driver: default
      config:
        - subnet: 192.168.89.0/24
          gateway: 192.168.89.254

services:
EOF

hostid=1
for vmname in vm1 vm2 vm3 vm4 vm5 vm6 vm7 vm8 vm9 vm10 vm11
do
  cat << EOF
  $vmname:
    build: sshd-container
    image: hana/sshd-container
    container_name: "$vmname"
    networks:
      upperlink:
        ipv4_address: 192.168.87.$hostid
      lowerlink:
        ipv4_address: 192.168.88.$hostid
      maintainlink:
        ipv4_address: 192.168.89.$hostid
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
