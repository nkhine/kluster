#!/bin/bash

nvidia-smi -c 1 # Set compute-exclusive mode.  If this fails due to no such
     # program, it's OK.


for f in /dev/nvidia{0,1,2,3,4,5,6}  /dev/nvidiactl; do
   chmod 666 $f 2>/dev/null
done
