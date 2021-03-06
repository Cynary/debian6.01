#!/bin/bash

# # Wait for network to be up for 10s
# # 1/.2 = 5
# count=0
# while ! (ping -c 1 sicp-s4.mit.edu &> /dev/null) && ((count<120*5))
# do
#     sleep 0.2
#     ((count++))
# done

update() {
    # If network not up, then we failed
    ( ping -c 1 sicp-s4.mit.edu &> /dev/null ) || exit 1;

    # Run the update
    cd /etc/601/scratch
    # Update lib601
    # Update stuff
    # Maybe someday this'll be a daemon that gets commands from s4, polls it,
    # or has some smart connection to it. Make sure to edit systemd file as well.
    echo "Updating 6.01 `date`" >> /etc/601/log
}

case $1 in
    "start")
	update
	;;
    "stop")
	;;
esac
