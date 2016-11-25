export KLUSTER_HOME=/home/cpupa/kluster-test/kluster

export EC2_HOME=$KLUSTER_HOME/ec2

# set JAVA_HOME
if [ "`uname`" == Darwin ]; then
  if ! export JAVA_HOME=`/usr/libexec/java_home` ; then
    echo "**Error setting JAVA_HOME: check that you have Java installed.**"
  fi
else
  export JAVA_HOME=/usr
  if [ ! -f ${JAVA_HOME}/bin/java ]; then
    echo "**Cannot find Java in ${JAVA_HOME}/bin: either install java there, or modify vars.sh to set"
    echo "**the path correctly."
  fi
fi

. $KLUSTER_HOME/keys.sh || echo "Error reading $KLUSTER_HOME/keys.sh"

export PATH=$EC2_HOME/bin:$KLUSTER_HOME/bin:$PATH

