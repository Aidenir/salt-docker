#!/bin/bash
docker build -f Dockerfile-centos7 -t ${1}/saltstack-centos7 .
docker build -f Dockerfile-centos6 -t ${1}/saltstack-centos6 .
docker build -f Dockerfile-ubuntu16.04 -t ${1}/saltstack-ubuntu16.04 .
