#!/bin/bash

if [ ! -f bin/compare-configs.sh ]; then
  echo "$0: you need to run this script from the kluster root directory."
  exit 1;
fi

if [ $# -lt 3 ]; then
  echo "Usage: $0 ssh-private-key instance-name script1 [script2] ... "
fi

sshkey=$1; shift
instance=$1; shift

[ ! -f $sshkey ] && echo "$0: expecting ssh key file $sshkey to exist." && exit 1;

echo -n "Testing ssh... "
! ssh -i $sshkey root@$instance true && echo "$0: error ssh-ing to $instance" && exit 1;
echo "Done."

for f in $*; do
  echo "Processing file $f ... "
  if [ ! -f scripts/$f ]; then
    echo "$0: ignoring script we do not have: ${scripts}/$f"
  fi
  cat scripts/$f | ssh -i $sshkey root@$instance "cat > /tmp/tmpf; \
  if [ ! -f $f ]; then \
    echo 'Config file $f does not exist'
  elif ! cmp $f /tmp/tmpf >& /dev/null; then echo 'Config file $f differs, diff is: '; diff /tmp/tmpf $f; \
  else echo 'File $f unchanged'; fi"
done
