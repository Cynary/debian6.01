#!/bin/bash
# Exit only if it is possible to connect to sicp-s4
function wait_s4() {
    echo "Waiting for S4 to come online"
    while ! (ping -c 1 sicp-s4.mit.edu &> /dev/null)
    do
	sleep 0.2
    done
    echo "I can now connect to S4"
}    

case $1 in
    "start")
	echo $PPID > /etc/601/connected_pid
	wait_s4
	rm /etc/601/connected_pid
	;;
    "stop")
	if [ -e /etc/601/connected_pid ]
	then
	    echo "Stopping the wait for S4"
	    kill -s KILL `cat /etc/601/connected_pid`
	    rm /etc/601/connected_pid
	    echo "S4 wait is hopefully stopped now"
	fi
	;;
esac
