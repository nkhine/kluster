#!/bin/bash

if [ ! -f ec2-api-tools.zip ]; then
  wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip || exit 1;
fi

unzip -o ec2-api-tools.zip > foo || exit 1;

name=`grep inflating foo | awk '{print $2}' | cut -d/ -f1 | head -1` || exit 1;
rm ec2 2>/dev/null
echo "Linking $name to ec2"
ln -s $name ec2

# now modify vars.sh to set KLUSTER_HOME correctly.

echo "Putting the line  export KLUSTER_HOME=`pwd`  in ./vars.sh"

grep -v 'export KLUSTER_HOME=' vars.sh > foo || exit 1;
! echo "export KLUSTER_HOME=`pwd`" | cat - foo > vars.sh && \
   echo "Error creating vars.sh!  Check the contents of 'foo' for data you may have lost" && exit 1;

if  [ ! -f keys.sh ]; then
  echo "Creating example keys.sh file"
  echo "export AWS_ACCESS_KEY=ABCDEFGIPFDASZFDAXYZ" > keys.sh
  echo "export AWS_SECRET_KEY=ABCXPQB8LPOfDA9pbiUzFFDASFsAFDA3PFfpXYZ" >> keys.sh
fi


rm foo



