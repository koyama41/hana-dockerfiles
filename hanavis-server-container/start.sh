#! /bin/sh

echo "Waiting database "

for i in `seq 1 100`
do
  if [ -r /var/run/mysqld/mysqld.sock ]; then
    echo ""
    sleep 1
    if /opt/hhh-v11n/hhh_v11n_server/manage.py syncdb --noinput; then
      echo "Start rc.hhh"
      exec /etc/hhh/rc.hhh
    fi
  else
    echo -n "."
  fi
  sleep 1
done

# start failed
exit 1
