#!/bin/bash

# Run this as a deamon process from service. For general implementation read
#
# * http://www.rcamilleri.com/blog/linux-create-a-daemon-and-init-d-script/
#
# and
#
# * http://www.linux.com/learn/tutorials/442412-managing-linux-daemons-with-init-scripts
#
# For CentOS specific implementation read
#
# * http://www.cyberciti.biz/tips/linux-write-sys-v-init-script-to-start-stop-service.html

readonly SLEEP=30
readonly HOSTNAME=$(hostname -f)
readonly URL="http://${HOSTNAME}/localhost/dokuwiki/doku.php?id=start"

while true
do
  /usr/bin/logger -t "fhj-timer.sh" "woke up from sleep"
  # curl "${URL}" &>/dev/null 2>&1
  sleep ${SLEEP}
done

exit 0
