#!/bin/bash

# Variables from environement
: "${SALT_USE:=master}"
: "${SALT_NAME:=$(hostname)}"
: "${LOG_LEVEL:=info}"
: "${OPTIONS:=}"

if hash yum 2>/dev/null ; then
	OS=centos
elif hash apt-get 2>/dev/null ; then
	OS=ubuntu
else
	echo "Neither ubuntu nor centos"
	exit 1
fi

# Set minion id
echo $SALT_NAME > /etc/salt/minion_id

# If salt master also start minion in background
if [ $SALT_USE == "master" ]; then
  /usr/bin/salt-key -D
  echo "INFO: Starting salt-minion and auto connect to salt-master"
  if [[ ${OS} == "ubuntu" ]]; then
  	service salt-minion start
  elif [[ ${OS} == "centos" ]]; then
  	/usr/bin/salt-minion --log-level=$LOG_LEVEL $OPTIONS &
  	echo "INFO: Started salt-minion with pid: $!"
  fi
fi

# Set salt grains
if [ ! -z "$SALT_GRAINS" ]; then
  echo "INFO: Set grains on $SALT_NAME to: $SALT_GRAINS"
  echo $SALT_GRAINS > /etc/salt/grains
fi

# Start salt-$SALT_USE
echo "INFO: Starting salt-$SALT_USE with log level $LOG_LEVEL with hostname $SALT_NAME"
/usr/bin/salt-$SALT_USE --log-level=$LOG_LEVEL $OPTIONS
