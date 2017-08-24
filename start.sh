#!/bin/bash

# Variables from environement
: "${SALT_USE:=master}"
: "${SALT_NAME:=$(hostname)}"
: "${LOG_LEVEL:=info}"
: "${MASTER_LOG_LEVEL:=info}"
: "${OPTIONS:=}"

if hash yum 2>/dev/null ; then
	if [[ -f /etc/os-release ]]; then
		VERSION=7
		SYSTEMD=true
	else
		VERSION=6
		SYSTEMD=false
	fi
	OS=centos
elif hash apt-get 2>/dev/null ; then
	OS=ubuntu
	SYSTEMD=true
else
	echo "Neither ubuntu nor centos"
	exit 1
fi

# Set minion id
echo $SALT_NAME > /etc/salt/minion_id

# Set salt grains
if [ ! -z "$SALT_GRAINS" ]; then
  echo "INFO: Set grains on $SALT_NAME to: $SALT_GRAINS"
  echo $SALT_GRAINS > /etc/salt/grains
fi

#Template out the config files with the log levels
if [ $SALT_USE == "master" ]; then
	sed "s/LOG_LEVEL/${MASTER_LOG_LEVEL}/" /etc/salt/master_template > /etc/salt/master
fi
sed "s/LOG_LEVEL/${LOG_LEVEL}/" /etc/salt/minion_template > /etc/salt/minion

SetupSystem(){
	sleep 1
	if [[ ${SYSTEMD} == "true" ]]; then
		systemctl enable salt-minion
		systemctl start salt-minion
		journalctl --follow _PID=1 &
		journalctl --follow -u salt-minion &
		if [ $SALT_USE == "master" ]; then
			systemctl enable salt-master;
			systemctl start salt-master
			journalctl --follow -u salt-master &
		fi
	else
		chkconfig salt-minion on
		service salt-minion start
		if [ $SALT_USE == "master" ]; then
			chkconfig salt-master on
			service salt-master start

			# The following is an ugly hack on centos 6.
			# Because of some bug a thread creashes and
			# the easiest way is to restart the salt-master
			sleep 5
			netstat -plnt | grep 4505
			while [[ $? == "0" ]]; do
				sleep 1;
				service salt-master stop
				netstat -plnt | grep 4505
			done
			service salt-master start
			tail -F /var/log/salt/master /var/log/minion &
		else
			tail -F /var/log/salt/minion &
		fi
	fi

}

SetupSystem &
if [[ ${SYSTEMD} == "true" ]]; then
	exec /usr/sbin/init
else
	exec /sbin/init
fi