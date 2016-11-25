#!/bin/bash

prog=$(basename $0)
logger="logger -t $prog"

# note, we're setting this up for the 2015 workshop for using GPU machines
# that provide one GPU (g2.2xlarge), and we're configuring the queue in
# such a way that a separate queue g.q is used
# This script, for GPU machines, will add the machine with one slot
# to queue gpu.q.

for n in $(seq 3); do
    nvidia-smi # /dev/nvidiactl doesn't become visible till you run this.
    if [ ! -e /dev/nvidiactl ]; then
	sleep 20;
    fi
done

if [ -e /dev/nvidiactl ]; then
    temp=$(mktemp)
    if ! qconf -se $(hostname) > $temp; then
	$logger "$0: Error running qconf -se $hostname"
	service kluster-configure-queue restart
    fi
    if ! qconf -se $(hostname) > $temp; then
	$logger "$0: Error running qconf -se $hostname a second time, exiting"
	exit 0;
    fi
    output=$(qconf -aattr hostgroup hostlist $(hostname) @gpuhosts) # make sure we're in @gpuhosts
    $logger "Added $hostname to @gpuhosts, exit status is $?, output is $output"
else
    $logger "$0: this machine does not seem to be a GPU machine"
fi

