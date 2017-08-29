Easy Salt testing with Docker
===========

This repo provides a Salt setup with one master and one (or multiple) minions to be able to test and work with states, pillars and all other salt functionality. By using docker it's easy to reproduce and test you code.

Image includes both salt-master, salt-minion to be able to test and troubleshoot all things salt. `SALT_USE` environment variable is used to determent if container should be running as master or minion.

Each container spawned as a minion or a master runs an init system (Systemd or SysV), and the salt daemons run using this init system, meaning `service` or `systemctl` can be used inside the containers. The images using Systemd are also configured to run a docker daemon, so its possible to run salt states that spawn containers inside the minion containers. This is done to make the containers  as similar to real servers as possible. But this is also why the containers needs to run as privileged ones, so use this only in test environments.

Salt master is auto accepting all minions.

## Versions

### Salt
This repo currently uses salt version **2016.11.2**, but changing to the latest version is possible.

### Linux Distribution
There are three dockerfiles, one for each of these versions:

- **CentOS 7**(using Systemd)
- **CentOS 6**(using SysV)
- **Ubuntu 16.04** (using Systemd)

## Get it running

### Salt master/minon with docker run
Run one container with a master/minion setup, using the Ubuntu 16.04 image.

```
docker run -i -t \
	--name=saltdocker_master_1 \
	-h master \
	-p 4505-4506:4505-4506 \
	-e SALT_USE=master \
	--privileged
	-v /sys/fs/cgroup:/sys/fs/cgroup:ro \
	--tmpfs /tmp \
	--tmpfs /run \
	artefacts.dataductus.se/saltstack-ubuntu16.04
```

By jumping in with `docker exec -i -t saltdocker_master_1 bash` your able to test/troubleshoot. Now your ready to write you states and test them out.

### Salt cluster with docker compose

Using [docker-compose](https://github.com/docker/compose) is an easy way to get a multi-minion setup running. Copy and configure `docker-compose.yml.example` to `docker-compose.yml` and run the following

```
docker-compose up
```

By jumping in with `docker-compose exec master /bin/bash` you're able to test/troubleshoot. Now you're ready to write you states and test them out.

## Environment variables

Env variables are used to set config on startup, you can set the following envs

 - `SALT_USE`  - master/minion, defaults to master
 - `SALT_GRAINS` - set minion grains as json, defaults to none
 - `LOG_LEVEL` - log level for the minion daemon, defaults to info
 - `MASTER_LOG_LEVEL` - log level for the master daemon, defaults to info

## Volumes

Following paths can be mounted from the container. `/srv/salt` is needed to run your local states.

 - `/etc/salt` - Master/Minion config
 - `/var/cache/salt` - job data cache
 - `/var/logs/salt` - logs
 - `/srv/salt` - states, pillar reactors

## Build


### Build the docker image by yourself
If you prefer you can easily build the docker image by yourself. After this the image is ready for use on your machine and can be used for multiple starts. Substitute repository_name with your own name for example.

```
git clone git@github.com:jacksoncage/salt-docker.git
cd salt-docker
bash ./build.sh <<repository-name>>
```

