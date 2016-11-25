#!/bin/bash

# You can install packages here:
#apt-get install -y <package-list>

# actually we put any misc stuff in here.
# the following was not being done by our image.

#qmod -d "all.q@`hostname`" # Disable this queue for now. (temp, for gpu instance which might not work well)


rm /etc/dhcp/dhclient-exit-hooks.d/hostname  # This is only needed
# for the GPU images.

