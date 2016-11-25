#!/bin/bash

prog=$(basename $0)
logger="logger -t $prog"

# c.f. ../kluster-start.d/y_remove_gpus_from_queue.sh

if [ -e /dev/nvidiactl ]; then
    qconf -dattr hostgroup hostlist $(hostname) @gpuhosts 
    $logger "Removed $hostname from @gpuhosts, exit status is $?, output is $output"
else
   logger "$0: this machine does not seem to be a GPU machine"
fi

