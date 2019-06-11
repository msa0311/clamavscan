#!/bin/bash
# bootstrap clam av service and clam av database updater shell script
# presented by mko (Markus Kosmal<dude@m-ko.de>)
set -m

# start clam service itself and the updater in background as daemon
freshclam -d &
clamd &

# start java spring rest service
java -jar /var/clamav-rest/clamav-rest-1.0.2.jar --clamd.host=127.0.0.1 --clamd.port=3310 --clamd.timeout=10000 --clamd.maxfilesize="110000KB" --clamd.maxrequestsize="110000KB"

# recognize PIDs
pidlist=`jobs -p`

# initialize latest result var
latest_exit=0

# define shutdown helper
function shutdown() {
    trap "" SIGINT

    for single in $pidlist; do
        if ! kill -0 $single 2>/dev/null; then
            wait $single
            latest_exit=$?
        fi
    done

    kill $pidlist 2>/dev/null
}

# run shutdown
trap shutdown SIGINT
wait

# return received result
exit $latest_exit
