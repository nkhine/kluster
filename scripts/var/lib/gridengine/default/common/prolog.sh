#!/bin/bash

function test_ok {
  if [ ! -z "$JOB_SCRIPT" ] && [ "$JOB_SCRIPT" != QLOGIN ] && [ "$JOB_SCRIPT" != QRLOGIN ]; then
    if [ ! -f "$JOB_SCRIPT" ]; then
       echo "$0: warning: no such file $JOB_SCRIPT, will wait" 1>&2
       return 1;
    fi
  fi
  if [ ! -z "$SGE_STDERR_PATH" ]; then
    if [ ! -d "`dirname $SGE_STDERR_PATH`" ]; then
      echo "$0: warning: no such directory $JOB_SCRIPT, will wait." 1>&2
      return 1; 
    fi
  fi
  return 0;
}

if ! test_ok; then
  sleep 2;
  if ! test_ok; then
     sleep 4;
     if ! test_ok; then
        sleep 8;
     fi
  fi
fi

exit 0;
