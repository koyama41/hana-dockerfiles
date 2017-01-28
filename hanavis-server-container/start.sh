#! /bin/sh

MANAGE_PY="/opt/hhh-v11n/hhh_v11n_server/manage.py"

echo "Waiting database "

for i in `seq 1 100`
do
  if [ -r /var/run/mysqld/mysqld.sock ]; then
    echo ""
    sleep 1
    if $MANAGE_PY syncdb --noinput; then
      $MANAGE_PY addhanadaemonconsole --csv /etc/hhh/nodes.csv
      echo "Start rc.hhh"
      export RES_OPTIONS='ndots:2'
      sh /etc/hhh/rc.hhh
      while true
      do
        echo "--- Current Process Status ---"
        ps -aef
        sleep 60
      done
    fi
  else
    echo -n "."
  fi
  sleep 1
done

# start failed
exit 1
